from pydantic import BaseModel

class UserSearchResponse(BaseModel):
    id: int
    username: str
    #avatar_url: str | None = None
    #status: str | None = None