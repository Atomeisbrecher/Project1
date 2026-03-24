from typing import Annotated
from fastapi import FastAPI, Path
from pydantic import BaseModel, EmailStr
import jinja2
import redis
import uvicorn


from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi import Request, Form, HTTPException
from fastapi.templating import Jinja2Templates

from auth.auth import router as r
import uuid
import hashlib
import base64

app = FastAPI()
app.include_router(router=r)
@app.get("/")
def create_jwt() -> dict:
    jwt: dict = {"token": "aa"}
    return jwt

# def create_user():
#     pass
#
# def validate_email():
#     pass
#
# def sign_in():
#     pass
#
# def sign_out():
#     pass
#
# def create_password():
#     pass
#
# def forget_password():
#     pass
#
# def unique_link():
#     pass
#
# def block_user():
#     pass
#
# def unblock_user():
#     pass
#
# def confirm_email():
#     pass
#
# def confirm_phone():
#     pass

auth_codes = {}

templates = Jinja2Templates(directory="templates")

@app.get('/auth', response_class=HTMLResponse)
async def login_oauth21(
    request: Request,
    client_id: str,
    redirect_uri: str,
    code_challenge: str,
    state: str,
    response_type: str = "authorization_code",
):
    if client_id != "my_flutter_app":
        raise HTTPException(status_code=400, detail="Invalid client_id")
    print(state)
    response = templates.TemplateResponse("login.html", {
        "request": request,
        "state": state,
        "client_id": client_id,
        "redirect_uri": redirect_uri,
        "code_challenge": code_challenge
    })
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Content-Security-Policy"] = "frame-ancestors 'none';"
    return response


@app.post('/login')
async def login(
    username: str = Form(...),
    password: str = Form(...),
    client_id: str = Form(...),
    redirect_uri: str = Form(...),
    code_challenge: str = Form(...),
    state: str = Form(...),
):
    if username != "admin" or password != "admin":
        raise HTTPException(status_code=401, detail="Invalid credentials")
    print(state)
    code = str(uuid.uuid4())
    auth_codes[code] = {
        "client_id": client_id,
        "code_challenge": code_challenge,
        "user_id": 123
    }
    return RedirectResponse(
        url=f"{redirect_uri}?code={code}&state={state}",
        status_code=302
    )

@app.post("/token")
async def post_token(
    code: str = Form(...),
    code_verifier: str = Form(...),
    client_id: str = Form(...),
    grant_type: str = Form("authorization_code"),
):
    auth_data = auth_codes.pop(code, None)
    if not auth_data:
        raise HTTPException(status_code=400, detail="Invalid or expired code")

    def verify_code_challenge(code_verifier: str, challenge_code: str) -> bool:
        digest = hashlib.sha256(code_verifier.encode('utf-8')).digest()
        expected_challenge = base64.urlsafe_b64encode(digest).decode('utf-8').replace("=", '')
        return challenge_code == expected_challenge
    
    stored_challenge = auth_data["code_challenge"]
    if not verify_code_challenge(code_verifier, stored_challenge):
        raise HTTPException(status_code=400, detail="PKCE validation failed")


    return {
        "access_token": "fake-access-token-for-user-123",
        "refresh_token": "fake-refresh-token",
        "token_type": "Bearer",
        "expires_in": 3600
    }


@app.post('/auth/logout')
async def logout(
    #token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)
):
    # await redis.set(f"blacklist:{token}", "true", ex=ACCESS_TOKEN_EXPIRE_MINUTES * 60)
    # db_user_token = db.query(RefreshToken).filter(RefreshToken.token == token).first()
    # if db_user_token:
    #     db.delete(db_user_token)
    #     db.commit()
        
    return {"message": "Successfully logged out"}

from core.config import settings
import jwt
redis_client = redis.Redis(host='localhost', port=6379, db=0)
@app.get("/oidc/logout")
async def oidc_logout(request: Request, id_token_hint: str, post_logout_redirect_uri: str):
    try:
        token_data = jwt.decode(id_token_hint, settings.auth_jwt.public_key_path.read_text(), algorithms=["RS256"])
        user_id = token_data.get("sub")
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ID Token")

    # 2. Удаление сессии пользователя из Redis
    # Redis хранит активные токены/сессии
    redis_client.delete(f"user_session:{user_id}")
    
    # 3. Редирект обратно в приложение (через кастомную схему URI)
    # Например: myapp://callback/logout
    return RedirectResponse(url=post_logout_redirect_uri)

if __name__ == "__main__":
    uvicorn.run("main:app", reload = True)