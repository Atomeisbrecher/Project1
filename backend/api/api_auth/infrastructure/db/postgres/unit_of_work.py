from api_auth.infrastructure.db.postgres.user_repository import PGUserRepository
from api_auth.domain.interfaces import IUnitOfWork


class SQLAlchemyUnitOfWork(IUnitOfWork):
    def __init__(self, session):
        self.session = session
        self.users = PGUserRepository(session)

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if exc_type:
            await self.rollback()


    async def commit(self):
        await self.session.commit()

    async def rollback(self):
        await self.session.rollback()