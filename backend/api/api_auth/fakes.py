import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from infrastructure.db.postgres.orm import UserORM
import bcrypt

async def create_admin():
    # Замени на свою строку подключения
    DATABASE_URL = "postgresql+asyncpg://my_admin:super_secret_db_pass@localhost:5432/app_db"
    engine = create_async_engine(DATABASE_URL)
    session_factory = async_sessionmaker(engine)

    async with session_factory() as session:
        # Хэшируем пароль "admin"
        password = "admin"
        salt = bcrypt.gensalt()
        pwd_bytes: bytes = password.encode()
        hashed_password=  bcrypt.hashpw(pwd_bytes, salt)
        
        admin = UserORM(
            id=1,
            username="admin",
            pwdhash=hashed_password.decode('utf-8'),
            email="admin@example.com" # если добавил это поле
        )

        session.add(admin)
        await session.commit()
        print("Фейковый админ успешно создан!")

if __name__ == "__main__":
    asyncio.run(create_admin())