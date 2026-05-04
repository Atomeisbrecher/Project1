from sqlite3 import IntegrityError

from sqlalchemy import select

from api_auth.domain.interfaces import IUserRepository
from orm.orm import UserORM
from api_auth.domain.entities import UserEntity, UserCreate
from sqlalchemy.ext.asyncio import AsyncSession
import logging

logger = logging.getLogger(__name__)

class PGUserRepository(IUserRepository):
    def __init__(self, session: AsyncSession):
        super().__init__()
        self.session = session

    async def get_by_email(self, email: str) -> UserEntity | None:
        pass
    
    async def get_by_username(self, username: str) -> UserEntity:
        stmt = select(UserORM).where(UserORM.username == username)
        logger.debug("Looking for username match")
        result = await self.session.execute(stmt)
        logger.debug(f"Found: {result}")
        return result.scalar_one_or_none()

    async def get_user_by_id(self, user_id: int) -> UserEntity | None:
        stmt = select(UserORM).where(UserORM.id == int(user_id))
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def create_user(self, user: UserCreate) -> UserEntity:
        """Создает пользователя из UserCreate DTO и возвращает UserEntity"""
        logger.info(f"Creating user: email={user.email}, username={user.username}")
        user_orm = UserORM(
            email=user.email,
            phone=user.phone,
            pwdhash=user.password,
            username=user.username
        )
        logger.debug(f"UserORM instance created: {user_orm}")
        self.session.add(user_orm)
        logger.debug("User added to session")
        
        await self.session.flush()
        logger.debug("Session flushed successfully")

        result = UserEntity(
            id=user_orm.id,
            email=user_orm.email,
            phone=user_orm.phone,
            username=user_orm.username,
            password_hash_bytes=user_orm.pwdhash
        )
        logger.info(f"User created successfully: id={result.id}, email={result.email}")
        return result


    async def update_user_by_id(self, user_id: str) -> UserEntity:
        pass

    async def delete_user_by_id(self, user_id: str) -> None:
        pass