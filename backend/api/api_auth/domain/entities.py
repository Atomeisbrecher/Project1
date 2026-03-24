from dataclasses import dataclass
import json

@dataclass
class UserEntity():
    email: str
    password_hash_bytes: bytes
    username: str
    phone: str | None = None

class UserCreate():
    pass

class UserUpdate():
    pass

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