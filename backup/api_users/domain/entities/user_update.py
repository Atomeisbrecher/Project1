from backend.api_core.domain.entities import CustomModel

class UserUpdate(CustomModel):
    """
    Domain model for updating user information.

    Represents a partial update operation for a user entity.

    Attributes:
        id: ID of the user to be updated.
        email: New email address (optional).
        is_active: Whether the user should be active (optional).
        is_superuser: Whether the user should be a superuser (optional).
        is_verified: Whether the user is verified (optional).
    """
    id: int
    email: str | None = None
    is_active: bool | None = True
    is_superuser: bool | None = False
    is_verified: bool | None = False