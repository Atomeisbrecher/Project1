from pydantic import BaseModel, Field


class RefreshRequest(BaseModel):
    refresh_token: str = Field(..., description="Текущий refresh токен")

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "Bearer"


class UserSearchResponse(BaseModel):
    id: int
    username: str
    #avatar_url: str | None = None
    #status: str | None = None