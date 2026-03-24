from fastapi import APIRouter
from backend.api_auth.presentation.dependencies import PasswordHasherDep
from backend.crud.router import CRUDRouter
from backend.api_users.application.use_cases.user_delete import delete_user
from backend.api_users.application.use_cases.user_profile import get_user_profile
from backend.api_users.application.use_cases.user_create import register_user
from backend.api_users.application.use_cases.user_update import update_user
from backend.api_users.domain.dto.user_create_dto import UserCreateDTO
from backend.api_users.domain.dto.user_update_dto import UserUpdateDTO
from backend.api_users.domain.dto.user_read_dto import UserReadDTO
from backend.api_users.infrastructure.db.crud import UserService
from backend.api_users.presentation.dependencies import UserUoWDep

user_api_router = APIRouter()

@user_api_router.post("/", response_model=UserReadDTO)
async def register(user_data: UserCreateDTO, pwd_hasher: PasswordHasherDep, uow: UserUoWDep):
    return await register_user(user_data, pwd_hasher = pwd_hasher, uow = uow)

@user_api_router.get("/{user_id}", response_model=UserReadDTO)
async def get_profile(user_id: int, uow: UserUoWDep):
    return await get_user_profile(user_id, uow = uow)

@user_api_router.patch("/{user_id}", response_model=UserReadDTO)
async def update(user_id: int, user_data: UserUpdateDTO, uow: UserUoWDep):
    return await update_user(user_id, user_data, uow = uow)

@user_api_router.delete("/{user_id}")
async def delete(user_id: int, uow: UserUoWDep):
    return await delete_user(user_id, uow = uow)


class UserCRUDRouter(CRUDRouter):
    """
    CRUD router configuration for the user entity.

    Attributes:
        crud: User service implementing CRUDBase.
        create_schema: Schema for user creation.
        update_schema: Schema for user update.
        read_schema: Schema for reading user data.
        router: FastAPI router instance.
    """
    crud = UserService()
    create_schema = UserCreateDTO
    update_schema = UserUpdateDTO
    read_schema = UserReadDTO
    router = APIRouter()
