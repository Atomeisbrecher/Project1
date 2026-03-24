import datetime
from enum import Enum




class TokenType(str, Enum):
    ACCESS = "access"
    REFRESH = "refresh"

class TokenData():
    user_id: int
    exp: datetime.datetime
    jti: str | None = None


class AnonymousUser():
    id: None = None
    email: None = None
    hashed_password: None = None

    def __bool__(self) -> bool:
        return False