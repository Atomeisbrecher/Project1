from dishka import make_async_container
from fastapi import FastAPI
from fastapi.concurrency import asynccontextmanager
from api_auth.presentation.auth_api import router as auth_router
from api_chat.presentation.chat_api import router as chat_router
import uvicorn
from dishka.integrations.fastapi import setup_dishka
from api_auth.presentation.ioc import AuthProvider
import logging
import sys
from sqlalchemy.ext.asyncio import AsyncEngine, async_sessionmaker

from api_chat.presentation.chat_ioc import ChatProvider

logger = logging.getLogger("my_app")
logger.setLevel(logging.DEBUG)

file_handler = logging.FileHandler("app.log")
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)

logger.addHandler(file_handler)


@asynccontextmanager
async def lifespan(app: FastAPI):
    container = app.state.dishka_container
    await container.get(AsyncEngine)
    await container.get(async_sessionmaker)
    # TODO: Создать таблицы через миграции (Alembic) или вручную через pgadmin
    #await db_manager.init_db()
    yield
    await container.close()


app = FastAPI(lifespan=lifespan)
container = make_async_container(AuthProvider(), ChatProvider())
setup_dishka(container, app)

app.include_router(router=auth_router, prefix="/auth", tags=["auth"])
app.include_router(router=chat_router, prefix="/chats", tags=["chats"])

if __name__ == "__main__":
    logger.info("Starting server...")

    uvicorn.run(
        "main:app",
        reload=True,
        log_level="debug",
        reload_excludes=["*.log", "app.log"],
    )

