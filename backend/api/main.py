import asyncio
import socket
from typing import AsyncGenerator, AsyncIterable

from dishka import make_async_container
from fastapi import FastAPI
from fastapi.concurrency import asynccontextmanager
from sqlalchemy import NullPool, text
from api_auth.presentation.routing import router as auth_router
from api_chat.presentation.chat_api import router as chat_router
import uvicorn
from dishka.integrations.fastapi import setup_dishka
from api_auth.presentation.ioc import AuthProvider
from api_auth.infrastructure.db.postgres.session import DbManager
import logging
import sys
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, async_sessionmaker, create_async_engine

from api_auth.domain.interfaces import IUnitOfWork
from api_auth.infrastructure.db.postgres.orm import UserORM
# Configure root logger
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('app.log')
    ]
)
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)


@asynccontextmanager
async def lifespan(app: FastAPI):
    if sys.platform == 'win32':
        asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())
    container = app.state.dishka_container
    await container.get(AsyncEngine)
    await container.get(async_sessionmaker)
    # TODO: Создать таблицы через миграции (Alembic) или вручную через pgadmin
    #await db_manager.init_db()
    yield
    await container.close()


app = FastAPI(lifespan=lifespan)
container = make_async_container(AuthProvider())
setup_dishka(container, app)

app.include_router(router=auth_router, prefix="/auth", tags=["auth"])
app.include_router(router=chat_router, prefix="/chats", tags=["chats"])

if __name__ == "__main__":

    logger.info("Starting server...")
    uvicorn.run(
        "main:app",
        reload=True,
        log_level="debug",
        access_log=True,
    )

