from datetime import datetime, timedelta, timezone
from uuid import uuid4

from fastapi import HTTPException, Request, Response

from api_auth.domain.interfaces import ITokenAuth, ITokenProvider, ITokenStorage
from api_auth.domain.token_entity import TokenType, TokenData
from auth_config import settings

from api_auth.domain.entities import UserEntity
import jwt

TOKEN_TYPE_FIELD = "type:"

class TokenProvider(ITokenProvider):   

    def _encode_jwt(
            self,
            payload: dict,
            private_key: str = settings.auth_jwt.private_key_path.read_text(),
            algorithm: str = settings.auth_jwt.algorithm,
            expire_minutes: int = 5,
            expire_timedelta: timedelta | None = None,
        ) -> str:
        to_encode: dict = payload.copy()
        now = datetime.now(timezone.utc)

        if expire_timedelta:
            expire = now + expire_timedelta
        else:
            expire = now + timedelta(minutes = expire_minutes)

        to_encode.update(
            exp=expire,
            iat=now,
        )

        encoded = jwt.encode(
            to_encode,
            private_key,
            algorithm=algorithm,
        )
        return encoded

    def _decode_jwt(
            self,
            token: str | bytes,
            public_key: str = settings.auth_jwt.public_key_path.read_text(),
            algorithm: str = settings.auth_jwt.algorithm,
    ) -> dict:
        decoded = jwt.decode(
            token,
            public_key,
            algorithms=algorithm,
        )
        return decoded

    def _create_jwt(
            self,
            token_type: str,
            token_data: dict,
            expire_minutes: int = settings.auth_jwt.access_token_expire_minutes,
            expire_timedelta: timedelta | None = None,
            ) -> str:
        jwt_payload = {
            TOKEN_TYPE_FIELD: token_type,
            "jti": str(uuid4())
            }
        jwt_payload.update(token_data)
        return self._encode_jwt(
            payload=jwt_payload,
            expire_minutes=expire_minutes,
            expire_timedelta=expire_timedelta,
            )         

    def create_access_token(self, data: dict) -> str:
        return self._create_jwt(
            token_type=TokenType.ACCESS.value,
            token_data=data,
            expire_minutes=settings.auth_jwt.access_token_expire_minutes,
            )

    def create_refresh_token(self, data: dict) -> str:
        return self._create_jwt(
            token_type=TokenType.REFRESH.value,
            token_data=data,
            expire_timedelta=timedelta(days=settings.auth_jwt.refresh_token_expire_days),
        )

class TokenAuth(ITokenAuth):
    def __init__(
            self,
            token_provider: ITokenProvider,
            token_storage: ITokenStorage,
            request: Request | None = None,
            response: Response | None = None,
            ):
        self.token_provider = token_provider
        self.token_storage = token_storage
        self.request = request
        self.response = response

    async def set_tokens(self, user_id: int | None = None) -> TokenData:
        data = {
            "sub": str(user_id),
        }
        access_token = self.token_provider.create_access_token(data)
        refresh_token = self.token_provider.create_refresh_token(data)
        result = TokenData(
            access_token=access_token,
            refresh_token=refresh_token,
            )  
        return result

    async def set_token(self, token: str, token_type: TokenType):
        pass

    async def revoke_tokens(self, user: UserEntity) -> None:
        self.token_storage.blacklist_tokens_by_user()


    def _get_access_token(self) -> str | None:
        if hasattr(self.request.state, "access_token"):
            return self.request.state.access_token

    def _get_refresh_token(self) -> str | None:
        if hasattr(self.request.state, "refresh_token"):
            return self.request.state.refresh_token  

    def _validate_token(self, token: str) -> dict | None:
        try:
            if self.token_storage:
                payload = self.token_provider._decode_jwt(token)
            jti = payload.get("jti")

            if token.token_storage:
                client = self.token_storage.client()
            if client.exists(f"blaclist:{jti}"):
                raise HTTPException(status_code=401, detail="Token has been revoked")
                
            return payload
        except Exception:
            raise HTTPException(status_code=401, detail="Invalid token")


class TokenStorage():
    #хранилище токенов
    pass