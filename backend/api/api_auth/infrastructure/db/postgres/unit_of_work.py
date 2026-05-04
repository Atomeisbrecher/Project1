from api_auth.infrastructure.db.postgres.user_repository import PGUserRepository
from api_auth.domain.interfaces import IUnitOfWork
from sqlalchemy.ext.asyncio import AsyncSession

import logging

logger = logging.getLogger(__name__)
class SQLAlchemyUnitOfWork(IUnitOfWork):
    def __init__(self, session: AsyncSession):
        logger.debug("Initializing SQLAlchemyUnitOfWork")
        self.session = session
        self.users = PGUserRepository(session)

    async def __aenter__(self):
        logger.debug("Entering Unit of Work context")
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        logger.debug(f"Exiting Unit of Work context, {exc_type}, {exc_val}, {exc_tb}")
        if exc_type:
            await self.rollback()
        else:
            pass


    async def commit(self):
        logger.debug("Committing transaction")
        await self.session.commit()

    async def rollback(self):
        logger.debug("Rolling back transaction")