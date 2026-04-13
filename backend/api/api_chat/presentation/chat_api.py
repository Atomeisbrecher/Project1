import asyncio

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from dishka.integrations.fastapi import FromDishka, inject
from fastapi import APIRouter

from api_auth.presentation.routing import CurrentUserPayload
from api_chat.presentation.chat_helpers import redis_listener, redis_to_ws_stream, ws_to_logic_stream
from api_chat.application.commands import SendMessageCommand
from api_chat.application.queries import SyncMessagesCommand

router = APIRouter()


class ChatManager:
    def __init__(self, redis_url: str):
        self.redis = redis.from_url(redis_url, decode_responses=True)

    # async def broadcast(self, user_id: int, event: ChatMessageEvent):
    #     await self.redis.publish(f"user_stream_{user_id}", event.model_dump_json())

    async def subscribe(self, user_id: int):
        pubsub = self.redis.pubsub()
        await pubsub.subscribe(f"user_stream_{user_id}")
        return pubsub

@router.post("/{chat_id}/messages")
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

@router.post("/sync")
@inject
async def sync_messages(
    chat_id: str,
    last_message_id: int | None = None,
    command: FromDishka[SyncMessagesCommand] = None
):
    messages = await command.execute(chat_id=chat_id, last_message_id=last_message_id)
    return {"messages": messages}

@router.websocket("/ws")
@inject
async def websocket_endpoint(
    websocket: WebSocket,
    manager: FromDishka[ChatManager]
):
    await websocket.accept()
    user_id = 123
    
    # Очередь — это наш локальный Event Loop для этого сокета
    event_queue = asyncio.Queue()
    pubsub = await manager.subscribe(user_id)
    
    # Запускаем слушатель Redis как отдельную фоновую задачу
    listen_task = asyncio.create_task(redis_listener(pubsub, event_queue))
    
    try:
        # Основной цикл обработки: Event Loop будит эту функцию 
        # только когда в очереди что-то появилось
        while True:
            # Ждем либо события из очереди, либо данных от клиента
            # wait_for_event() вернет данные, как только они физически поступят
            async with asyncio.TaskGroup() as tg:
                tg.create_task(redis_to_ws_stream(websocket, pubsub))
                tg.create_task(ws_to_logic_stream(websocket))
            done, pending = await asyncio.wait(
                [
                    asyncio.create_task(event_queue.get()),
                    asyncio.create_task(websocket.receive_text())
                ],
                return_when=asyncio.FIRST_COMPLETED
            )
            
            for task in done:
                result = task.result()
                if isinstance(result, str):
                    await websocket.send_text(result)
                
    except WebSocketDisconnect:
        listen_task.cancel()
    finally:
        await pubsub.unsubscribe(f"user_stream_{user_id}")
    #Короче ТЗ ещё очень сильно нужно доработать для нормально функционирующей системы
    