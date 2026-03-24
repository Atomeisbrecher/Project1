import json
from api_auth.domain.entities import CodeData
import redis.asyncio as redis


class RedisTokenStorage:
    def __init__(self, client: redis.Redis):
        self.redis = client
        self.ttl = 300

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

    async def save_code(self, code: str, user_id: int, challenge: str, ttl: int = 600):
        data = CodeData(user_id=user_id, challenge=challenge)
        key = f"auth_code:{code}"
        await self.redis.setex(key, ttl, data.to_json())

    async def get_field_by_name(self, field_name: str) -> CodeData | None:
        pass

    async def delete_field_by_name(self, field_name: str) -> CodeData | None:
        pass

    @property
    async def client(self):
        return self.redis
