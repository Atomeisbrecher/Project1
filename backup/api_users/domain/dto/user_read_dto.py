from backend.api_core.domain.entities import CustomModel

class UserReadDTO(CustomModel):
    """
    Data Transfer Object for user output.

    This model is designed to represent both authenticated and anonymous users,
    allowing unified usage in views like `/users/me`.

    Attributes:
        id: User ID (optional for anonymous users).
        email: Email address of the user.
        is_active: Whether the user account is active.
        is_superuser: Whether the user has administrative privileges.
        is_verified: Whether the user has verified their email.
    """
    id: int | None
    email: str | None
    is_active: bool = True
    is_superuser: bool = False
    is_verified: bool = False