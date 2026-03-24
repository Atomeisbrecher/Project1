
class UserService:
    def __init__(self, session: Session):
        self._db = session

    def list_users(self) -> list[User]:
        return self._db.query(User).all()
    
    def get_user_by_id(self, user_id: int) -> User | None:
        return self._db.query(User).filter(User id == user_id).first()

    def create_user(self, username: str) -> User | None:
        user = User(username = username )
        self._db.add(user)
        self._db.commit()
        self._db.refresh(user)
        return user

    def update_user(self, user_id: int, username: str) -> User | None:
        user = self.get_user_by_id(user_id)
        if not user:
            return None
        user.username = username
        self._db.commit()
        self._db.refresh(user)
        return user

    def delete_user(self, user_id: int) -> bool:
        user = self.get_user_by_id(user_id)
        if not user:
            return False
        self._db.delete(user)
        self._db.commit()
        return True