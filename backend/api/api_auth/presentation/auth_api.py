from typing_extensions import Annotated

from fastapi import APIRouter, Depends, Form, HTTPException, Header, Request
from fastapi.responses import RedirectResponse, HTMLResponse
from dishka.integrations.fastapi import FromDishka, inject
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from api_auth.application.interactors.get_login_page import get_login_page
from api_auth.application.interactors.login import LoginUseCase
from api_auth.application.dto.login import LoginInputDTO
from fastapi import status
import logging

from api_auth.domain.token_entity import TokenData
from api_auth.application.interactors.register import RegisterUser, RegisterUserCommand
from api_auth.domain.entities import UserCreate
from api_auth.application.interactors.exchange_code_for_token import ExchangeCodeForToken
from api_auth.domain.interfaces import ITokenAuth, ITokenProvider, IUnitOfWork, IUserRepository
from api_auth.presentation.dtos import RefreshRequest, TokenResponse, UserSearchResponse
router = APIRouter()
logger = logging.getLogger(__name__)


#TODO для удобства лучше вынести в отдельный файл эндпоинты для работы с юзером и под другим тегом

security_bearer = HTTPBearer()
@inject
async def get_current_user_payload(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security_bearer)],
    auth_service: FromDishka[ITokenProvider],
) -> dict:
    try:
        # validate_token выбросит HTTPException(401), если токен отозван
        payload = auth_service.extract_payload(credentials.credentials)
        return payload
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
        )

# Алиас для удобства
CurrentUserPayload = Annotated[dict, Depends(get_current_user_payload)]

@router.get("/", response_class=HTMLResponse)
async def authorize(
    request: Request,
    client_id: str,
    redirect_uri: str,
    state: str,
    code_challenge: str,
    ):
    logger.info(f"Received authorization request for client_id={client_id}")
    return await get_login_page(request, client_id, redirect_uri, state, code_challenge)

@router.post('/login')
@inject
async def login(
    username: str = Form(...),
    password: str = Form(...),
    client_id: str = Form(...),
    redirect_uri: str = Form(...),
    code_challenge: str = Form(...),
    state: str = Form(...),
    use_case: FromDishka[LoginUseCase] = None,
):
    dto = LoginInputDTO(
        username=username,
        password=password,
        client_id=client_id,
        redirect_uri=redirect_uri,
        code_challenge=code_challenge,
        state=state,
    )
    try:
        result = await use_case.execute(dto)
        return_url = (
            f"{result.redirect_uri}?"
            f"code={result.auth_code}&"
            f"state={result.state}"
        )

        return RedirectResponse(url=return_url, status_code=status.HTTP_302_FOUND)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, 
            detail=str(e)
        )


@router.post("/token", response_model=TokenResponse)
@inject
async def post_token(
    code: str = Form(...),
    code_verifier: str = Form(...),
    #client_id: str = Form(...),
    grant_type: str = Form("authorization_code"),
    use_case: FromDishka[ExchangeCodeForToken] = None,
):
    if grant_type != "authorization_code":
        raise HTTPException(status_code=400, detail="Unsupported grant type")
    try:
        tokens = await use_case.execute(code, code_verifier)
        return tokens
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/refresh", response_model=TokenResponse)
@inject
async def refresh_tokens(
    auth_header: Annotated[str | None, Header(alias="Authorization")] = None,
    x_refresh_token: Annotated[str | None, Header(alias="X-Refresh-Token")] = None,
    auth_service: FromDishka[ITokenAuth] = None,
):
    if not auth_header or not x_refresh_token:
        raise HTTPException(status_code=401, detail="Missing tokens in headers")

    auth_header = auth_header.replace('Bearer ','')

    old_access = auth_header
    old_refresh = x_refresh_token
    old_payload = auth_service.token_provider.extract_payload(old_refresh)
    user_id = int(old_payload.get("sub"))
    new_tokens = await auth_service.rotate_tokens(
        user_id,
        old_access_token=old_access,
        old_refresh_token=old_refresh
    )
    return new_tokens


#TODO Везде при работе с защищенными эндпоинтами надо сделать проверку их в белом списке.
@router.post("/refresh", response_model=TokenResponse)
@inject
async def refresh_tokens(
    request_data: RefreshRequest,
    auth_service: FromDishka[ITokenAuth],
    token: str = Depends(HTTPBearer(auto_error=False))
):
    """Юз-кейс ротации: меняет старую пару токенов на новую."""
    old_access = token
    old_refresh = request_data.refresh_token
    try:
        old_payload = auth_service.token_provider.extract_payload(old_refresh)
        user_id = int(old_payload["sub"])
        
        new_tokens = await auth_service.rotate_tokens(user_id, old_access, old_refresh)
        return TokenResponse(
            access_token=new_tokens.access_token,
            refresh_token=new_tokens.refresh_token
        )
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Refresh failed: {str(e)}")


@router.post("/register")
@inject
async def register(
    data: UserCreate, 
    use_case: FromDishka[RegisterUser] = None
):
    logger.debug(f"Received registration request for username={data.username}, email={data.email}")
    cmd = RegisterUserCommand(
        username=data.username,
        email=data.email,
        password=data.password,
        phone=data.phone,
    )
    logger.debug(f"Calling use case for user registration")
    result = await use_case(cmd)
    logger.debug(f"Registration successful, user id={result.id}")

    return {
        "id": result.id if result.id else None,
        "username": result.username,
        "email": result.email,
        "phone": result.phone,
        "access_token": None,
        "refresh_token": None,
    }

# @router.get("/logout")
# @inject
# async def logout_oidc(
#     id_token_hint: str,
#     post_logout_redirect_uri: str,
#     auth_service: FromDishka[ITokenAuth]
# ):
#     await auth_service.revoke_by_id_token(id_token_hint)
#     return RedirectResponse(url=post_logout_redirect_uri)


@router.post("/logout")
@inject
async def logout(
    auth_header: Annotated[str | None, Header(alias="Authorization")] = None,
    x_refresh_token: Annotated[str | None, Header(alias="X-Refresh-Token")] = None,
    auth_service: FromDishka[ITokenAuth] = None
):
    if not auth_header or not x_refresh_token:
        raise HTTPException(status_code=401, detail="Missing tokens in headers")
    auth_header = auth_header.replace('Bearer ','')
    await auth_service.revoke_specific_session(auth_header, x_refresh_token)
    return {"detail": "Successfully logged out from current device"}

@router.post("/logout-all")
@inject
async def logout_all(
    payload: CurrentUserPayload,
    auth_service: FromDishka[ITokenAuth]
):
    user_id = int(payload["sub"])
    await auth_service.revoke_all_sessions(user_id)
    return {"detail": "Successfully logged out from all devices"}

@router.post("/change-password")
async def change_password():
    #TODO реализовать эндпоинт для изменения пароля, который будет требовать текущий пароль и новый пароль,
    # а также проверять аутентификацию и права доступа.
    # Необходимо реализовать смену пароля с инвалидацией всех сессий. Подтверждение через email или OTP.
    pass

@router.patch("/update")
async def update_user():
    #TODO реализовать эндпоинт для обновления данных пользователя (кроме пароля)
    pass

@router.get("/me", response_model=UserSearchResponse)
@inject
async def get_current_user_profile(
    payload: CurrentUserPayload,
    uow: FromDishka[IUnitOfWork]
):
    user_id = payload.get("sub")
    async with uow:
        result = await uow.users.get_user_by_id(user_id)
        if result:
            return result
        else:
            return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

@router.get("/users/{username}", response_model=UserSearchResponse)
@inject
async def get_user_by_username(
    payload: CurrentUserPayload,
    username: str,
    uow: FromDishka[IUnitOfWork] = None,
    ):
    async with uow:
        result = await uow.users.get_by_username(username)
        if result:
            print(result)
            return result
        else:
            return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

@router.delete("/users/{user_id}")
async def delete_user(user_id: str):
    #TODO реализовать эндпоинт для удаления пользователя по id, который будет требовать аутентификацию и проверку прав доступа.
    pass


# @router.post('token-test')
# @inject
# async def token_test(
#     user_id: int,
#     auth_service: FromDishka[ITokenAuth],
#     ):
#     tokens = await auth_service.set_tokens(user_id)
#     return tokens
    


#TODO добавить валидацию данных при регистрации и обновлении (например, проверку формата email)
#TODO добавить обработку ошибок при регистрации (например, если пользователь с таким email уже существует)
# и возвращать понятные сообщения об ошибках клиенту.
#TODO добавить логирование важных событий, таких как успешная регистрация,
# неудачные попытки входа и т.д. для мониторинга и отладки.
