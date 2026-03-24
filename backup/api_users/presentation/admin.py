from sqladmin import ModelView

from backend.api_users.infrastructure.db.orm import UserDB


class UserAdmin(ModelView, model=UserDB):
    column_list = [UserDB.id, UserDB.email]