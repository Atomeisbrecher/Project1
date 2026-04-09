from dataclasses import dataclass
import logging

from api_auth.domain.interfaces import IPasswordHasher, IUnitOfWork, IUserRepository
from api_auth.domain.entities import UserCreate, UserEntity

logger = logging.getLogger(__name__)

@dataclass
class RegisterUserCommand:
    email: str
    phone: str | None
    username: str
    password: str

class RegisterUser:
    def __init__(self, hasher: IPasswordHasher, uow: IUnitOfWork):
        self.hasher = hasher
        self.uow = uow
    
    async def __call__(self, cmd: RegisterUserCommand) -> UserEntity:
        async with self.uow as uow:
            logger.info(f"Checking if user with username={cmd.username} already exists")
            user_exists = await uow.users.get_by_username(cmd.username)
            if user_exists:
                logger.error("User with this username already exists")
                raise ValueError("User with this username already exists")
            
            logger.info(f"Hashing password for user {cmd.username}")
            password_hash_str = self.hasher.hash_password(cmd.password)
            logger.debug(f"Password hashed successfully")
            
            user_dto = UserCreate(
                email=cmd.email,
                phone=cmd.phone,
                username=cmd.username,
                password=password_hash_str
            )
            logger.debug(f"UserCreate DTO created")

            new_user = await uow.users.create_user(user_dto)
            await uow.commit()
        return new_user