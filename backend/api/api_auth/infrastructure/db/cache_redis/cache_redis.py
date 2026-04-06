from datetime import time
import json

from fastapi import HTTPException, status
from api_auth.domain.entities import CodeData
from api_auth.domain.token_entity import TokenData
import redis.asyncio as redis

MAX_SESSIONS = 5

class RedisTokenStorage:
    def __init__(self, client: redis.Redis):
        self.redis = client
        self.code_ttl = 300


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

    async def get_field_by_name(self, field_name: str) -> CodeData | None:
        pass

    async def delete_field_by_name(self, field_name: str) -> CodeData | None:
        pass

    async def allowlist_token(self, user_id: int, jti: str, expire_seconds: time):
        #user_session:{user_id} = jti, code_ttl = expire_seconds
        key = f"user_sessions:{user_id}"
        now = time.time()
        async with self.redis.pipeline(transaction = True) as pipe:
            await pipe.zadd(key, {jti: now})

            await pipe.zremrangebyrank(key, 0, -(MAX_SESSIONS + 1))

            await pipe.expire(key, expire_seconds)
            await pipe.setex(f"allowlist:{jti}", expire_seconds, "1")
            await pipe.execute()
    
    async def is_session_valid(self, user_id: int, jti: str) -> bool:
        score = await redis.zscore(f"user_sessions:{user_id}", jti)
        if score is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session expired or limit reached")
        return True

    async def revoke_all_tokens_by_user_id(self, user_id: int) -> dict:
        key = f"user_sessions:{user_id}"
        await redis.delete(key)
        return {"status": "all_sessions_revoked"}
    
    async def revoke_specific_token_by_user_id(self, user_id: int, jti: str) -> dict:
        key = f"user_sessions:{user_id}"
        result = await redis.zrem(key, jti)
        if result == 0:
            return {"status": "already_revoked"}

        return {"status": "success"}

    @property
    async def client(self):
        return self.redis
