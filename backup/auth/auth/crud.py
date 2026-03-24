from auth.models import UserSchema
from auth import utils as auth_utils

john = UserSchema(
    username = "john",
    password = auth_utils.hash_password("qwerty"),

)
sam = UserSchema(
    username = "sam",
    password = auth_utils.hash_password("password"),

)

users_db: dict[str, UserSchema] = {
    john.username: john,
    sam.username: sam
}