from dataclasses import dataclass
import json

from pydantic import EmailStr

@dataclass
class UserEntity():
    id: int
    username: str
    email: str
    password_hash_bytes: bytes
    phone: str | None = None

@dataclass
class UserCreate:
    username: str
    email: EmailStr
    password: str
    phone: str | None = None

@dataclass
class UserUpdate():
    id: int
    email: str | None = None
    username: str | None = None
    phone: str | None = None

@dataclass
class CodeData:
    user_id: int
    challenge: str
    scope: str = "default"

    def to_json(self) -> str:
        return json.dumps(self.__dict__)

    @classmethod
    def from_json(cls, data: str):
        return cls(**json.loads(data))