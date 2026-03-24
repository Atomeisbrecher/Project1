from typing import Annotated

from fastapi import Depends

from backend.api_users.domain.interfaces.user_uow import IUserUnitOfWork
from backend.api_users.infrastructure.db.unit_of_work import PGUserUnitOfWork


def get_user_uow() -> IUserUnitOfWork:
    return PGUserUnitOfWork()


UserUoWDep = Annotated[IUserUnitOfWork, Depends(get_user_uow)]