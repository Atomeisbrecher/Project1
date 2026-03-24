from backend.api_core.domain.entities import CustomModel

class User(CustomModel):
    """
    Domain model representing a user in the system.

    This entity encapsulates the core business attributes of a user,
    independent of how they are persisted or exposed externally.

    Attributes:
        id: Unique identifier of the user.
        email: Email address associated with the user.
        hashed_password: Hashed password for authentication.
        is_active: Indicates whether the user is currently active.
        is_superuser: Indicates whether the user has administrative privileges.
        is_verified: Indicates whether the user has verified their email address.
    """
    id: int
    email: str
    hashed_password: str
    is_active: bool
    is_superuser: bool
    is_verified: bool