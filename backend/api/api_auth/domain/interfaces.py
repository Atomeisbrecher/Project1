from abc import ABC, abstractmethod
from dataclasses import dataclass

from api_auth.domain.entities import UserEntity, UserCreate, CodeData

class IUserRepository(ABC):
    @abstractmethod
    async def get_by_email(self, email: str) -> UserEntity | None:
        pass
    
    @abstractmethod
    async def get_by_user_id(self, user_id: str) -> UserEntity | None:
        pass

    @abstractmethod
    async def get_by_username(self, username: str) -> UserEntity | None:
        pass
    
    @abstractmethod
    async def create_user(self, user: UserCreate) -> UserEntity:
        pass

    @abstractmethod
    async def update_user_by_id(self, user_id: str) -> UserEntity:
        pass

    @abstractmethod
    async def delete_user_by_id(self, user_id: str) -> None:
        pass
    
class IUnitOfWork(ABC):
    @abstractmethod
    async def commit(self): ...

    @abstractmethod
    async def rollback(self): ...

    @abstractmethod
    async def __aenter__(self) -> "IUnitOfWork": ...

    @abstractmethod
    async def __aexit__(self, *args): ...


class ITokenProvider(ABC):

    @abstractmethod
    def create_access_token() -> str:
        pass

    @abstractmethod
    def create_refresh_token() -> str:
        pass

class ITokenStorage(ABC):
    def __init__():
        pass

    @abstractmethod
    async def save_code(self, code: str, data: CodeData, ttl: int): pass
    
    @abstractmethod
    async def get_and_delete_code(self, code: str) -> CodeData | None: pass

    @abstractmethod
    async def get_field_by_name(self, field_name: str) -> CodeData | None: pass

    @abstractmethod
    async def delete_field_by_name(self, field_name: str) -> CodeData | None: pass

class ITokenAuth(ABC):
    def __init__(self, token_storage: ITokenStorage, token_provider: ITokenProvider):
        self.token_provider = token_provider
        self.token_storage = token_storage

    @abstractmethod
    async def set_tokens(self, user: UserEntity) -> None: pass

    @abstractmethod
    async def revoke_tokens(self, user: UserEntity) -> None: pass



class IPasswordHasher(ABC):
    @abstractmethod
    def hash_password(password: str | bytes) -> bytes:
        pass
    
    @abstractmethod
    def validate_password(
        password: str,
        hashed_password: bytes,
    ) -> bool:
        pass
