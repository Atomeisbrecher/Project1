from dataclasses import dataclass
from pydantic import Field
from fastapi import Form
@dataclass(frozen=True)
class LoginInputDTO:
    username: str
    password: str# = Field(min_length=6, max_length=50)
    client_id: str
    redirect_uri: str
    code_challenge: str
    state: str
    
    # @classmethod
    # def as_form(
    #     cls,
    #     username: str = Form(...),
    #     password: str = Form(..., min_length=6, max_length=50)
    # ):
    #     return cls(username=username, password=password)

@dataclass(frozen=True)
class LoginOutputDTO:
    auth_code: str
    state: str
    redirect_uri: str