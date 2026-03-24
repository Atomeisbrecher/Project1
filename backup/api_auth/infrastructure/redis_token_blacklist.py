from backend.api_auth.domain.interfaces.token_storage import ITokenStorage
from backend.api_auth.domain.interfaces.token_auth import TokenData
from backend.api_utils.datetimes import get_timezone_now
from backend.api_core.infrastructure.clients.redis import get_redis_client


class RedisTokenStorage(ITokenStorage):

    def __init__(self):
        self.redis = get_redis_client()

    async def store_token(self, token_data: TokenData) -> None:
        """Store a token."""
        key = f"tokens:{token_data.jti}"
        ttl = int((token_data.exp - get_timezone_now()).total_seconds())
        await self.redis.setex(key, ttl, token_data.user_id)
        await self.redis.sadd(f"user_tokens:{token_data.user_id}", token_data.jti)

    async def revoke_tokens_of_user(self, user_id: str) -> None:
        """Revoke user tokens."""
        token_keys = await self.redis.smembers(f"user_tokens:{user_id}")
        for jti in token_keys:
            await self.redis.delete(f"tokens:{jti}")
        await self.redis.delete(f"user_tokens:{user_id}")

    async def is_token_active(self, jti: str) -> bool:
        """Check if the current token is active"""
        return await self.redis.exists(f"tokens:{jti}") == 1