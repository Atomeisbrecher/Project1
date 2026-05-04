from sqlalchemy import text, event
from typing import AsyncIterable
import logging

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker, AsyncEngine
import asyncio

from orm.orm import Base

logger = logging.getLogger(__name__)

class DbManager:
    def __init__(self, url: str, echo: bool = True):
        logger.info(f"Creating async engine")
        self.engine = create_async_engine(
            url,
            connect_args={
                "ssl": False,
                "command_timeout": 5 # Чтобы код не висел вечно, а упал через 5 сек
                },
            echo=True
                )
        self.session_factory = async_sessionmaker(self.engine, expire_on_commit=False,)
        
        logger.info(f"Async engine created with dialect: {self.engine.dialect.name}")


    async def init_db(self):
        """Создает таблицы, если их нет"""
        async with self.engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        print("База данных проверена: таблицы созданы или уже существуют")