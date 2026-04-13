import asyncio
import queue

from fastapi import WebSocket, WebSocketDisconnect

async def redis_to_ws_stream(websocket: WebSocket, pubsub):
    """Событийный поток из Redis в клиент"""
    try:
        async for message in pubsub.listen():
            if message["type"] == "message":
                await websocket.send_text(message["data"])
    except Exception as e:
        # Логируем ошибку брокера
        pass

async def ws_to_logic_stream(websocket: WebSocket):
    """Событийный поток из клиента в бэкенд"""
    try:
        async for text in websocket.iter_text():
            # Здесь обрабатываем входящие от Flutter (например, 'read_event')
            pass
    except WebSocketDisconnect:
        raise # Пробрасываем выше для TaskGroup

async def redis_listener(websocket: WebSocket, pubsub):
    async for message in pubsub.listen():
        if message["type"] == "message":
            await websocket.send_text(message["data"])

async def keep_alive(ws: WebSocket):
    while True:
        await asyncio.sleep(30)
        await ws.send_json({"type": "ping"})

async def client_receiver(ws: WebSocket):
    while True:
        await ws.receive_text()