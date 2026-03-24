from jwt.exceptions import InvalidTokenError

from fastapi import (
    APIRouter,
    Depends,
    Form,
    HTTPException,
    status
)

from fastapi.security import (
    HTTPBearer,
    OAuth2PasswordBearer
)
from pydantic import BaseModel
from auth import utils as auth_utils
from auth.models import UserSchema
from auth.helpers import ACCESS_TOKEN_TYPE, REFRESH_TOKEN_TYPE, TOKEN_TYPE_FIELD, create_access_token, create_refresh_token
from auth.validate import get_current_auth_user_for_refresh, get_current_auth_user
from auth.crud import users_db


#openssl genrsa -out jwt-private.pem 2048
#openssl rsa -in jwt-private.pem -outform PEM -pubout -out jwt-public.pem


http_bearer = HTTPBearer(auto_error=False)

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/auth/auth/login"
)

class TokenInfo(BaseModel):
    access_token: str
    refresh_token: str | None = None
    token_type: str = "Bearer",

router = APIRouter(
    prefix="/auth",
    tags=["Auth"],
    dependencies=[Depends(http_bearer)]
    )


def validate_user(
        username: str = Form(),
        password: str = Form(),
) -> str:
    unauthed_exc = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="invalid username or password"
    )


    if not (user := users_db.get(username)):
        raise unauthed_exc
    
    if not auth_utils.validate_password(
        password = password,
        hashed_password = user.password,
    ):
        raise unauthed_exc
    
    if not user.active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="user inactive",
        )
    return user

def get_current_token_payload(
        token: str = Depends(oauth2_scheme),
) -> dict:
    try:
        payload = auth_utils.decode_jwt(
            token=token,
        )
    except InvalidTokenError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token error {e}",
        )
    return payload



def get_current_active_auth_user(
        user: UserSchema = Depends(get_current_auth_user)
)->UserSchema:
    if user.active:
        return user
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail = "user_inactive",
    )

@router.post("/login", response_model=TokenInfo)
def auth_user_issue_jwt(
    user: UserSchema = Depends(validate_user)
) -> TokenInfo:
    
    access_token=create_access_token(user)
    refresh_token = create_refresh_token(user)
    return TokenInfo(
        access_token = access_token,
        refresh_token= refresh_token,
    )

@router.post(
        "/refresh", 
        response_model=TokenInfo,
        response_model_exclude_none=True,
        )
def auth_refresh_jwt(user: UserSchema = Depends(get_current_auth_user_for_refresh)) -> TokenInfo:
    access_token = create_access_token(user)

    return TokenInfo(
        access_token=access_token
    )

@router.get("/users/me")
def auth_user_check_self_info(
    payload: dict = Depends(get_current_token_payload),
    user: UserSchema = Depends(get_current_active_auth_user),
) -> dict:
    iat = payload.get("iat")
    return {
        "username": user.username,
        "email": user.email,
        "logged_at": iat,
    }