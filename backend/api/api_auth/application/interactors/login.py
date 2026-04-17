import uuid

from api_auth.application.dto.login import LoginInputDTO, LoginOutputDTO
from api_auth.domain.interfaces import IPasswordHasher, ITokenStorage, IUnitOfWork


class LoginUseCase:
    def __init__(
            self, 
            uow: IUnitOfWork, 
            storage: ITokenStorage,
            hasher: IPasswordHasher
        ):
        self.uow = uow
        self.storage = storage
        self.hasher = hasher

            
    async def execute(self, dto: LoginInputDTO) -> LoginOutputDTO:
            async with self.uow as uow:
                try:
                    user = await self.uow.users.get_by_username(dto.username)

                    if not user or not self.hasher.validate_password(dto.password, user.pwdhash):
                        raise Exception("Invalid credentials")
                    
                    auth_code = str(uuid.uuid4())
                    await self.storage.save_code(
                        code=auth_code,
                        user_id=user.id,
                        challenge=dto.code_challenge
                        )
                    
                    await self.uow.commit()
                    
                    return LoginOutputDTO(
                        auth_code = auth_code,
                        state = dto.state,
                        redirect_uri = dto.redirect_uri,
                        )
                except Exception as e:
                    await self.uow.rollback()
                    raise Exception(f"Exception during login: {str(e)}")