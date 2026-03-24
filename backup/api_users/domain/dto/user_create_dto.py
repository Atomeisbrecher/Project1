import re

from pydantic import Field, field_validator

from backend.api_core.domain.constants import STRONG_PASSWORD_PATTERN
from backend.api_core.domain.entities import CustomModel


class UserCreateDTO(CustomModel):
    """
    Data Transfer Object for user creation.

    This model is used when registering a new user.
    It includes password validation and default flags for user status.

    Attributes:
        email: User email address.
        password: Raw password (must meet strong password requirements).
        is_active: Whether the user account is active.
        is_superuser: Whether the user has administrative privileges.
        is_verified: Whether the user's email is verified.
    """
    email: str
    password: str = Field(min_length=6, max_length=128)
    is_active: bool | None = False
    is_superuser: bool | None = False
    is_verified: bool | None = False

    @field_validator("password", mode="after")
    def valid_password(cls, password: str) -> str:
        """
        Validate password strength.

        Ensures the password contains at least one lowercase letter,
        one uppercase letter, one digit or special character.

        :param password: Raw user password.
        :return: Validated password.
        :raises ValueError: If password does not match the required pattern.
        """
        if not re.match(STRONG_PASSWORD_PATTERN, password):
            raise ValueError(
                "Password must contain at least "
                "one lower character, "
                "one upper character, "
                "digit or special symbol"
            )

        return password