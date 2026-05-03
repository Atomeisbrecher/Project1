from pydantic import BaseModel, Field


class RefreshRequest(BaseModel):
    refresh_token: str = Field(..., description="Текущий refresh токен")

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "Bearer"


class UserSearchResponse(BaseModel):
    id: str
    username: str
    picture: str = ''

    model_config = {
        "from_attributes": True,
        "coerce_numbers_to_str": True # Принудительное приведение чисел к строкам
    }
    #avatar_url: str | None = None
    #status: str | None = None