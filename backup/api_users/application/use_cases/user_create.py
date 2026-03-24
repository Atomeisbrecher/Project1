from backend.api_users.domain.entities.user_create import UserCreate
from backend.api_users.domain.entities.user import User
from backend.api_users.domain.interfaces.password_hasher import IPasswordHasher
from backend.api_users.domain.interfaces.user_uow import IUserUnitOfWork
from backend.api_users.domain.dto.user_create_dto import UserCreateDTO


async def register_user(
    user_data: UserCreateDTO,
    pwd_hasher: IPasswordHasher,
    uow: IUserUnitOfWork,
) -> User:
    """
    Register a new user in the system.

    This function hashes the password, creates a new user entity,
    saves it to the database, and commits the transaction.

    :param user_data: Data transfer object containing user registration details.
    :param pwd_hasher: Password hasher
    :param uow: Unit of work instance for handling user repository operations.
    :return: Newly created user object.
    """
    user_data = UserCreate(
        **user_data.model_dump(mode='json'),
        hashed_password=pwd_hasher.hash(user_data.password)
    )
    async with uow:
        new_user = await uow.users.add(user_data)
        await uow.commit()
    return new_user