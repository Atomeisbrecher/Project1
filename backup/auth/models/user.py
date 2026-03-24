from pydantic import BaseModel
from dataclasses import dataclass
#models == dto

@dataclass(slots=True, frozen=True)
class UserCreate(BaseModel):
    username: str

class UserRead(BaseModel):
    id: int
    username: str