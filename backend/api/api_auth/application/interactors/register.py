from dataclasses import dataclass

from api_auth.domain.interfaces import IPasswordHasher, IUserRepository
from api_auth.domain.entities import UserEntity

@dataclass
class RegisterUserCommand:
    email: str
    phone: str
    username: str
    password: str

class RegisterUser:
    def __init__(self, repo: IUserRepository, hasher: IPasswordHasher):
        self.repo = repo
        self.hasher = hasher

    async def __call__(self, cmd: RegisterUserCommand) -> UserEntity:
        password_hash_bytes = self.hasher.hash_password(cmd.password)
        password_hash_str = password_hash_bytes.decode('utf-8')
        new_user = UserEntity(
            email = cmd.email,
            phone = cmd.phone,
            username = cmd.username,
            password_hash_bytes = password_hash_str
        )

        return await self.repo.create_user(new_user)