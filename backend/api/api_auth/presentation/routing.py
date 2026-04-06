
from fastapi import APIRouter, Form, HTTPException, Request
from fastapi.responses import RedirectResponse, HTMLResponse
from dishka.integrations.fastapi import FromDishka, inject
from pydantic import BaseModel, EmailStr
from api_auth.application.interactors.get_login_page import get_login_page
from api_auth.application.interactors.login import LoginUseCase
from api_auth.application.dto.login import LoginInputDTO
from fastapi import status
import logging

from api_auth.infrastructure.db.postgres.session import DbManager
from api_auth.infrastructure.db.postgres.unit_of_work import SQLAlchemyUnitOfWork
from api_auth.domain.interfaces import IPasswordHasher
from api_auth.domain.token_entity import TokenData
from api_auth.application.interactors.register import RegisterUser, RegisterUserCommand
from api_auth.domain.entities import UserCreate
from api_auth.application.interactors.exchange_code_for_token import ExchangeCodeForToken

router = APIRouter()
logger = logging.getLogger(__name__)

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


@router.post("/token", response_model=TokenData)
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
    
@router.post("/refresh")
async def refresh():
    pass

@router.post("/logout")
async def logout():
    pass

class RegisterRequest(BaseModel):
    username: str
    password: str
    email: EmailStr
    phone: str | None = None

@router.post("/register")
@inject
async def register(
    data: RegisterRequest, 
    # uow: FromDishka[SQLAlchemyUnitOfWork] = None,
    # hasher: FromDishka[IPasswordHasher] = None,
    use_case: FromDishka[RegisterUser] = None
):
    logger.info(f"Received registration request for username={data.username}, email={data.email}")
    cmd = RegisterUserCommand(
        username=data.username,
        email=data.email,
        password=data.password,
        phone=data.phone,
    )
    logger.debug("RegisterUserCommand created")
    #case = RegisterUser(hasher=hasher, uow=uow)
    logger.info(f"Calling use case for user registration")

    #result = await use_case(case(RegisterUserCommand))
    result = await use_case(cmd)
    logger.info(f"Registration successful, user id={result.id}")

    return {
        "id": result.id if result.id else None,
        "username": result.username,
        "email": result.email,
        "phone": result.phone
    }