from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import time
from typing import Protocol

from api_auth.domain.entities import UserEntity, UserCreate, CodeData
from api_auth.domain.token_entity import TokenData

class IUserRepository(Protocol):
    ...
    # @abstractmethod
    # async def get_by_email(self, email: str) -> UserEntity | None:
    #     pass
    
    # @abstractmethod
    # async def get_by_user_id(self, user_id: str) -> UserEntity | None:
    #     pass

    # @abstractmethod
    # async def get_by_username(self, username: str) -> UserEntity | None:
    #     pass
    
    # @abstractmethod
    # async def create_user(self, user: UserCreate) -> UserEntity:
    #     pass

    # @abstractmethod
    # async def update_user_by_id(self, user_id: str) -> UserEntity:
    #     pass

    # @abstractmethod
    # async def delete_user_by_id(self, user_id: str) -> None:
    #     pass
    
class IUnitOfWork(Protocol):
    @abstractmethod
    async def commit(self): ...

    @abstractmethod
    async def rollback(self): ...

    @abstractmethod
    async def __aenter__(self) -> "IUnitOfWork": ...

    @abstractmethod
    async def __aexit__(self, *args): ...


class ITokenProvider(Protocol):

    @abstractmethod
    def create_access_token() -> str:
        pass

    @abstractmethod
    def create_refresh_token() -> str:
        pass

class ITokenStorage(Protocol):
    ...
    # def __init__():
    #     pass
    # @abstractmethod
    # async def save_code(self, code: str, data: CodeData, ttl: int): pass
    
    # @abstractmethod
    # async def get_and_delete_code(self, code: str) -> CodeData | None: pass
    
    # @abstractmethod
    # async def allowlist_token(self, user_id: int, jti: str, expire_seconds: time):
    #     pass
    
    # @abstractmethod
    # async def is_session_valid(self, user_id: int, jti: str) -> bool:
    #     pass

    # @abstractmethod
    # async def revoke_all_tokens_by_user_id(self, user_id: int) -> dict:
    #     pass

    # @abstractmethod
    # async def revoke_specific_token_by_user_id(self, user_id: int, jti: str) -> dict:
    #     pass

class ITokenAuth(Protocol):
    ...
    # def __init__(self, token_storage: ITokenStorage, token_provider: ITokenProvider):
    #     self.token_provider = token_provider
    #     self.token_storage = token_storage

    # @abstractmethod
    # async def set_tokens(self, user: UserEntity) -> None: pass

    # @abstractmethod
    # async def revoke_all_tokens(self, user: UserEntity) -> None: pass



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
