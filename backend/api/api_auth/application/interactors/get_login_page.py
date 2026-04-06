from fastapi import HTTPException, Request
from fastapi.templating import Jinja2Templates


async def get_login_page(
    request: Request,
    client_id: str,
    redirect_uri: str,
    state: str,
    code_challenge: str,
    ):

    if client_id != "my_flutter_app":
        raise HTTPException(status_code=400, detail="Invalid client_id")
    response = Jinja2Templates(directory="templates").TemplateResponse(
        request = request,
        name="login.html",
        context={
        "state": state,
        "client_id": client_id,
        "redirect_uri": redirect_uri,
        "code_challenge": code_challenge
    })
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Content-Security-Policy"] = "frame-ancestors 'none';"
    return response