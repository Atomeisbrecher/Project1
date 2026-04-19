from typing import AsyncGenerator

import redis.asyncio as redis


class RedisStreamService:
    def __init__(self, client: redis.Redis):
        self.client = client


    async def publish_event(self, user_id: int, event_type: str, payload: dict):
        stream_key = f"user_events:{user_id}"
        data = {
            "type": event_type,
            "payload": str(payload),
        }
        await self.client.xadd(stream_key, data, maxlen=1000, approximate=True)


    async def listen_stream(self, user_id: int, last_message_id: str = "$") -> AsyncGenerator[list, None]:
        """
        Генератор, который слушает новые сообщения.
        last_id='$' означает слушать только новые.
        last_id='0' означает прочитать всё из истории.
        """
        stream_key = f"user_events:{user_id}"
        while True:
            response = await self.client.xread(
                {stream_key: last_message_id},
                count=10,
                block=0
            )

            if response:
                for stream, messages in response:
                    for msg_id, content in messages:
                        last_message_id = msg_id
                        yield content