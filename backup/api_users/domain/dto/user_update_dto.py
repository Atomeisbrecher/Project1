from backend.api_users.domain.entities.user_update import UserUpdate
from backend.api_core.domain.entities import CustomModel

class UserUpdateDTO(CustomModel):
    """
    Data Transfer Object for updating user information.

    This model is used in endpoints for partial updates to user data.

    Attributes:
        email: Updated email address (optional).
        is_active: Whether the user account is active.
        is_superuser: Whether the user has administrative privileges.
        is_verified: Whether the user has verified their email.
    """
    email: str | None = None
    is_active: bool | None = True
    is_superuser: bool | None = False
    is_verified: bool | None = False

    def to_entity(self, user_id: int):
        return UserUpdate(id=user_id, **self.model_dump(exclude_unset=True))