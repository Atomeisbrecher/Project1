import asyncio
import socket

from dishka import make_async_container
from fastapi import FastAPI
from fastapi.concurrency import asynccontextmanager
from api_auth.presentation.routing import router as auth_router
import uvicorn
from dishka.integrations.fastapi import setup_dishka
from api_auth.presentation.ioc import AuthProvider
from api_auth.infrastructure.db.postgres.session import DbManager
import logging
import sys

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
    db_manager = await container.get(DbManager)
    # TODO: Создать таблицы через миграции (Alembic) или вручную через pgadmin
    #await db_manager.init_db()
    yield
    await container.close()


app = FastAPI(lifespan=lifespan)
container = make_async_container(AuthProvider())
setup_dishka(container, app)

app.include_router(router=auth_router, prefix="/auth", tags=["auth"])


if __name__ == "__main__":

    logger.info("Starting server...")
    uvicorn.run(
        "main:app",
        reload=True,
        log_level="debug",
        access_log=True,
    )
