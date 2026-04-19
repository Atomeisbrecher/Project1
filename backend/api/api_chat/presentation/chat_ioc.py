import logging

from dishka import Provider, Scope, provide

import redis.asyncio as redis

from api_chat.presentation.chat_api import ChatManager
from api_chat.domain.interfaces import IRedisStreamService
from api_chat.infrastructure.db.redis_stream_service import RedisStreamService

logger = logging.getLogger(__name__)

class ChatProvider(Provider):
    @provide(scope=Scope.SESSION)
    def chat_manager(self, client: redis.Redis) -> ChatManager:
        return ChatManager(client=client)
    
    @provide(scope=Scope.APP)
    def redis_stream_service(self, client: redis.Redis) -> IRedisStreamService:
        return RedisStreamService(client = client)
    
