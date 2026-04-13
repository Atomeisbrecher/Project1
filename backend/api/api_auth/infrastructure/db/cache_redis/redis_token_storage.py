from datetime import datetime, time, timezone
import json

from fastapi import HTTPException, status
from api_auth.domain.entities import CodeData
from api_auth.domain.token_entity import TokenData
import redis.asyncio as redis

from api_auth.domain.interfaces import ITokenProvider, ITokenStorage


#TODO сделать public токен в виде opaque, а private простейший почти доверенный JWT

class RedisTokenStorage(ITokenStorage):
    def __init__(self, client: redis.Redis, token_provider: ITokenProvider):
        self.redis = client
        self.code_ttl = 300
        self.token_provider = token_provider
        self.max_sessions = 5

    async def get_and_delete_code(self, code: str) -> CodeData | None:
        key = f"auth_code:{code}"
        async with self.redis.pipeline(transaction=True) as pipe:
            pipe.get(key)
            pipe.delete(key)
            result, _ = await pipe.execute()
        if not result:
            return None
        try:
            return CodeData.from_json(result)
        except (json.JSONDecodeError, TypeError):
            return None

    async def save_code(self, code: str, user_id: int, challenge: str, code_ttl: int = 600):
        data = CodeData(user_id=user_id, challenge=challenge)
        key = f"auth_code:{code}"
        await self.redis.setex(key, code_ttl, data.to_json())

    async def create_session(self, user_id: int, token: TokenData):
        #user_session:{user_id} = jti, code_ttl = expire_seconds
        data = self.token_provider._decode_jwt(token)
        token_type = data.get("type")
        jti = data.get("jti")
        expire_timestamp = data.get("exp")
        iat = data.get("iat")
        key = f"user_sessions:{user_id}"

        expiration_time = int(expire_timestamp - iat)
        async with self.redis.pipeline(transaction = True) as pipe:

            if token_type == "refresh":
                await pipe.zadd(key, {jti: expiration_time})
                await pipe.zremrangebyrank(key, 0, -(MAX_SESSIONS + 1))
                await pipe.expire(key, expiration_time)

            await pipe.setex(f"allowlist:{jti}", expiration_time, "1")
            await pipe.execute()
    
    async def is_session_valid(self, user_id: int, jti: str) -> bool:
        score = await redis.zscore(f"user_sessions:{user_id}", jti)
        if score is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session expired or limit reached")
        return True

    
    async def rotate_session(
            self,
            user_id: int,
            old_access_token: TokenData,
            old_refresh_token: TokenData, 
            new_access_token: TokenData,
            new_refresh_token: TokenData
            ) -> dict:
        key = f"user_sessions:{user_id}"
        old_access_jti = self.token_provider._decode_jwt(old_access_token).get("jti")
        old_refresh_jti = self.token_provider._decode_jwt(old_refresh_token).get("jti")
        new_access_jti = self.token_provider._decode_jwt(new_access_token).get("jti")
        new_refresh_jti = self.token_provider._decode_jwt(new_refresh_token).get("jti")

        old_value = f"{old_access_jti}:{old_refresh_jti}"
        new_value = f"{new_access_jti}:{new_refresh_jti}"
        
        async with self.redis.pipeline(transaction=True) as pipe:
            await pipe.zrem(key, old_value)
            
            await pipe.zadd(key, {new_value: time()})
            
            await pipe.zremrangebyrank(key, 0, -11)
            
            await pipe.execute()

    async def revoke_specific_token_by_user_id(self, user_id: int, token: TokenData) -> dict:
        key = f"user_sessions:{user_id}"
        jti = self.token_provider._decode_jwt(token).get("jti")
        result = await redis.zrem(key, jti)
        await self.redis.delete(f"allowlist:{jti}")
        if result == 0:
            return {"status": "already_revoked"}
        return {"status": "success"}
    
    async def revoke_specific_session_by_user_id(self, user_id: int, access_token: TokenData, refresh_token: TokenData) -> dict:
        key = f"user_sessions:{user_id}"
        self.revoke_specific_token_by_user_id(user_id, refresh_token)
        self.revoke_specific_token_by_user_id(user_id, access_token)
        return {"status": "success"}

    async def revoke_all_sessions_by_user_id(self, user_id: int) -> dict:
        key = f"user_sessions:{user_id}"
        all_jtis = await self.redis.zrange(key, 0, -1)
        if not all_jtis:
            return {"status": "no_sessions"}
        async with self.redis.pipeline(transaction=True) as pipe:
            for jti in all_jtis:
                await pipe.delete(f"allowlist:{jti}")

            await pipe.delete(key)
            await pipe.execute()
        return {"status": "all_sessions_revoked"}



    def _key(self, user_id: int) -> str:
        return f"user_sessions:{user_id}"

    async def add_session(self, user_id: int, access_jti: str, refresh_jti: str, expire_seconds: int):
        key = self._key(user_id)
        val = f"{access_jti}:{refresh_jti}"
        
        async with self.redis.pipeline(transaction=True) as pipe:
            await pipe.zadd(key, {val: int(datetime.now().timestamp())})
            await pipe.zremrangebyrank(key, 0, -(self.max_sessions + 1))
            await pipe.expire(key, expire_seconds)
            await pipe.execute()

    async def is_session_valid(self, user_id: int, a_jti: str) -> bool:
        sessions = await self.redis.zrange(self._key(user_id), 0, -1)
        # Ищем, есть ли активная сессия с таким access_jti
        return any(s.decode().startswith(f"{a_jti}:") for s in sessions)

    async def rotate_session(self, user_id: int, old_value: str, new_value: str, expire_seconds: int):
        key = self._key(user_id)
        async with self.redis.pipeline(transaction=True) as pipe:
            await pipe.zrem(key, old_value)
            await pipe.zadd(key, {new_value: time.time()})
            await pipe.zremrangebyrank(key, 0, -(self.max_sessions + 1))
            await pipe.expire(key, expire_seconds)
            await pipe.execute()

    async def remove_session(self, user_id: int, a_jti: str, r_jti: str):
        val = f"{a_jti}:{r_jti}"
        await self.redis.zrem(self._key(user_id), val)

    async def remove_all_sessions(self, user_id: int):
        await self.redis.delete(self._key(user_id))

    @property
    async def client(self):
        return self.redis
