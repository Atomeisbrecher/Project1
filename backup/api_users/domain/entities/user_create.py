from backend.api_core.domain.entities import CustomModel

class UserCreate(CustomModel):
    """
    Domain model representing user data required for creation.

    Used to encapsulate the input necessary to create a new user in the system.

    Attributes:
        email: Email address of the new user.
        hashed_password: Secure hashed password.
        is_active: Whether the new user should be active.
        is_superuser: Whether the user has elevated privileges.
        is_verified: Whether the user's email is verified.
    """
    email: str
    hashed_password: str
    is_active: bool = True
    is_superuser: bool = False
    is_verified: bool = False