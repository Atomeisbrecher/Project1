import abc
from backend.api_auth.domain.entities.entities import TokenData

class ITokenProvider(abc.ABC):

    @abc.abstractmethod
    def create_access_token(self, data: dict) -> str:
        """Create a new access token"""
        pass

    @abc.abstractmethod
    def create_refresh_token(self, data: dict) -> str:
        """Create a new refresh token"""
        pass

    @abc.abstractmethod
    def read_token(self, token: str | None) -> TokenData | None:
        """Create a new access token"""
        pass
    