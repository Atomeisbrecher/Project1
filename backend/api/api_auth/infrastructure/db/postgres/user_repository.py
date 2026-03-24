from sqlite3 import IntegrityError

from sqlalchemy import select
from api_auth.domain.interfaces import IUserRepository
from api_auth.infrastructure.db.postgres.orm import UserORM
from api_auth.domain.entities import UserEntity, UserCreate


class PGUserRepository(IUserRepository):
    def __init__(self, session):
        self.session = session

    async def get_by_email(self, email: str) -> UserEntity | None:
        pass
    
    async def get_by_username(self, username: str) -> UserEntity | None:
        stmt = select(UserORM).where(UserORM.username == username)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_by_user_id(self, user_id: str) -> UserEntity | None:
        pass

    async def create_user(self, user: UserEntity) -> UserEntity:
        user_orm = UserORM(
            email=user.email,
            phone=user.phone,
            pwdhash=user.password_hash_bytes,
            username=user.username
        )
        
        self.session.add(user_orm)
        try:
            await self.session.commit()
            await self.session.refresh(user_orm)
        except Exception as e:
            print(f"Error {str(e)}")
        #user.id = user_orm.id
        return user


    async def update_user_by_id(self, user_id: str) -> UserEntity:
        pass

    async def delete_user_by_id(self, user_id: str) -> None:
        pass