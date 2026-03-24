import abc
from backend.api_auth.domain.entities.entities import TokenData, TokenType
from backend.api_auth.domain.interfaces.token_provider import ITokenProvider
from backend.api_auth.domain.interfaces.token_storage import ITokenStorage


class ITokenAuth(abc.ABC):

    def __init__(self, token_provider: ITokenProvider, token_storage: ITokenStorage | None = None):
        self.token_provider: token_provider
        self.token_provider: token_storage

    @abc.abstractmethod
    async def set_tokens(self, user: User) -> None:
        """Set new refresh/access tokens"""
        pass

    @abc.abstractmethod
    async def set_tokens(self, token: str, token_type: TokenType) -> None:
        """Set a specific token (by type) in the response."""
        pass
    @abc.abstractmethod
    async def unset_tokens(self, user: User) -> None:
        pass

    @abc.abstractmethod
    async def refresh_tokens(self, user: User) -> None:
        pass    

    @abc.abstractmethod
    async def read_token(self, token_type: TokenType) -> TokenData | None:
        pass   
    
    
