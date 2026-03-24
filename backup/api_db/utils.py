from backend.api_users.infrastructure.db.crud import UserService
from backend.api_db.base import Base
from backend.api_db.engine import engine

# Import models required for database initialization
from backend.api_users.infrastructure.db.orm import UserDB


async def create_db_and_tables():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def create_superuser(email: str, password: str):
    superuser = await UserService().get_by_email(email)
    if not superuser:
        superuser = await UserService().create(
            data={'email': email, 'password': password, 'is_active': True, 'is_superuser': True},
        )
        print('User created!')
    return superuser