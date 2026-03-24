

from datetime import time
import random


class RateLimiter:
    def __init__(self, redis: Redis):
        self.redis = redis

    async def is_limited(
            self,
            ip_address: str,
            endpoint: str,
            max_requests: int,
            time_window_seconds: int,
    ) -> bool:
        key = f"rate_limiter:{endpoint}:{ip_address}"

        current_ms = time() * 1000
        window_start_ms = current_ms - time_window_seconds * 1000

        current_request = f"{current_ms}-{random.randint(0, 100_000)}"
        async with self.redis.pipeline() as pipe:
            await pipe.zremrangebyscore(key, 0, window_start_ms)

            await pipe.zcard(key)

            await pipe.zadd(key, mapping = {current_request: current_ms})

            await pipe.expire(time_window_seconds)

            result = await pipe.execute()
        _, current_count, _, _ = result
        if current_count > max_requests: return True
