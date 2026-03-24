from dataclasses import dataclass
from enum import Enum


class TokenType(str, Enum):
    ACCESS = "access"
    REFRESH = "refresh"

@dataclass
class TokenData():
    access_token: str
    refresh_token: str | None = None
    token_type: str = "Bearer"
    