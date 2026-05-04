import asyncio
import datetime
from time import time
from typing import Annotated, Optional
import uuid

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
from api_chat.presentation.chat_dto import MessageRequest

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

# TODO: Сообщения всё же можно напрямую прокидывать через websocket, эндпоинт ниже
@router.post("/{chat_id}/message")
@inject
async def send_message(
    chat_id: str,
    request: MessageRequest,
    payload: CurrentUserPayload,
    redis: FromDishka[IRedisStreamService]
):
    message_id = str(uuid.uuid4())
    timestamp = datetime.datetime.now().isoformat()
    message_number = int(time() * 1000)
    msg_data = {
        "id": str(message_id),
        "chat_id": str(chat_id),
        "sender_id": str(payload.get("sub")),
        "text": request.text,
        "timestamp": timestamp,
        "status": "sent",
        "message_number": message_number,
        "reply_to_message_id": request.reply_to_message_id or "",
        "edited_at": "",
    }
    #await db.messages.add(message_data)
    # user_event:{chat_id} (chatid == user_id)
    if (msg_data["chat_id"] != msg_data["sender_id"]):
        await redis.send_message(msg_data)
    return msg_data

@router.get("/")
@inject
async def get_chats(
    offset: int,
    limit: int,
):
    return {"chats": []}
    
@router.get("/{chat_id}/messages")
@inject
async def get_messages(
    chat_id: str,
    offset: int,
    limit: int,
):
    return {"messages": []}



#one-to-one
@router.get("/{user_id}/{receiver_id}")
@inject
async def get_messages(
    user: CurrentUserPayload
):
    pass

@router.get("/{chat_id}")
@inject
async def get_chats(
    user: CurrentUserPayload
):
    pass

#group
@router.post("/group/create")
@inject
async def create_group_chat():
    pass

@router.post("/group/{group_id}/add")
@inject
async def add_group_member():
    pass

@router.post("/group/{group_id}/remove")
@inject
async def remove_group_member():
    pass

@router.get("/group/{group_id}/messages")
@inject
async def get_group_messages():
    pass

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
    if payload is None:
        raise WebSocketException(code=status.WS_1008_POLICY_VIOLATION)
    user_id = payload.get('sub')
    await websocket.accept()
    try:
        async for message in stream_service.listen_stream(user_id, 0):
            await websocket.send_json(message)
            
    except WebSocketDisconnect:
        print(f"User {user_id} disconnected")
    finally:
        await websocket.close()

@router.websocket("/ws/messages/send")
@inject
async def send_message(
    websocket: WebSocket,
    credentials: Annotated[str, Depends(get_cookie_or_token)]
):
    pass
