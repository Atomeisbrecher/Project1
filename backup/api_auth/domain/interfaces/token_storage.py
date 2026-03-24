import abc
from backend.api_auth.domain.entities.entities import TokenData

class ITokenStorage(abc.ABC):
    
    @abc.abstractmethod
    async def store_token(self, token: TokenData) -> None:
        """Store a token."""
        pass
    
    @abc.abstractmethod
    async def revoke_tokens_of_user(self, user_id: str) -> None:
        """Revoke user tokens."""
        pass
    
    @abc.abstractmethod
    async def is_token_active(self, jti: str) -> bool:
        """Check if the current token is active"""
        pass