import asyncio
from typing import Annotated, Optional

from fastapi import Cookie, Depends, FastAPI, Header, Query, Request, WebSocket, WebSocketDisconnect, WebSocketException
from dishka.integrations.fastapi import FromDishka, inject
from fastapi import APIRouter, status
from fastapi.security import HTTPAuthorizationCredentials
import redis.asyncio as redis

from api_auth.presentation.auth_api import CurrentUserPayload
from api_chat.presentation.chat_helpers import redis_listener, redis_to_ws_stream, ws_to_logic_stream
from api_chat.application.commands import SendMessageCommand
from api_chat.application.queries import SyncMessagesCommand
from api_auth.domain.interfaces import ITokenProvider
from api_auth.infrastructure.services.jwt.jwt_service import TokenProvider
from api_chat.domain.interfaces import IRedisStreamService

router = APIRouter()


class ChatManager:
    def __init__(self, client: redis.Redis):
        self.redis = client

    # async def broadcast(self, user_id: int, event: ChatMessageEvent):
    #     await self.redis.publish(f"user_stream_{user_id}", event.model_dump_json())

    async def subscribe(self, user_id: int):
        pubsub = self.redis.pubsub()
        await pubsub.subscribe(f"user_stream_{user_id}")
        return pubsub


@router.post("/sync")
@inject
async def sync_messages(
    chat_id: str,
    last_message_id: int | None = None,
    command: FromDishka[SyncMessagesCommand] = None
):
    messages = await command.execute(chat_id=chat_id, last_message_id=last_message_id)
    return {"messages": messages}

@router.websocket("ws/{chat_id}/messages")
@inject
async def send_message(
    chat_id: str,
    text: str,
    payload: CurrentUserPayload,
    command: FromDishka[SendMessageCommand]
):
    await command.execute(
        sender_id=int(payload["sub"]),
        chat_id=chat_id,
        text=text
    )
    return {"status": "sent"}






async def get_cookie_or_token(
    websocket: WebSocket,
    session: Annotated[str | None, Cookie()] = None,
    token: Annotated[Optional[str], Header(alias="access-token")] = None,
):
    token = websocket.headers.get("access-token")
    print(token)
    if session is None and token is None:
        raise WebSocketException(code=status.WS_1008_POLICY_VIOLATION)
    return session or token

@router.websocket("/ws")
@inject
async def websocket_endpoint(
    websocket: WebSocket,
    credentials: Annotated[str, Depends(get_cookie_or_token)],
    token_provider: FromDishka[ITokenProvider],
    stream_service: FromDishka[IRedisStreamService],
):
    payload = token_provider.extract_payload(credentials)
    print(payload)
    if payload is None:
        raise WebSocketException(code=status.WS_1008_POLICY_VIOLATION)
    user_id = payload.get('sub')
    await websocket.accept()
    try:
        async for message in stream_service.listen_stream(user_id, 0):
            await websocket.send_json(message)
            
    except WebSocketDisconnect:
        print(f"User {user_id} disconnected")


    # Очередь — это наш локальный Event Loop для этого сокета
    #event_queue = asyncio.Queue()
    #pubsub = await manager.subscribe(user_id)
    #listen_task = asyncio.create_task(redis_listener(pubsub, event_queue))
    
    # try:
    #     while True:
    #         async with asyncio.TaskGroup() as tg:
    #             tg.create_task(redis_to_ws_stream(websocket, pubsub))
    #             tg.create_task(ws_to_logic_stream(websocket))
    #         done, pending = await asyncio.wait(
    #             [
    #                 asyncio.create_task(event_queue.get()),
    #                 asyncio.create_task(websocket.receive_text())
    #             ],
    #             return_when=asyncio.FIRST_COMPLETED
    #         )
            
    #         for task in done:
    #             result = task.result()
    #             if isinstance(result, str):
    #                 await websocket.send_text(result)
                
    # except WebSocketDisconnect:
    #     listen_task.cancel()
    # finally:
    #     await pubsub.unsubscribe(f"user_stream_{user_id}")
    #Короче ТЗ ещё очень сильно нужно доработать для нормально функционирующей системы
    