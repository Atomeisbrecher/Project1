import bcrypt

from api_auth.domain.interfaces import IPasswordHasher

class BCryptPasswordHash(IPasswordHasher):
    
    def hash_password(self, password: str | bytes) -> bytes:
        salt = bcrypt.gensalt()
        pwd_bytes: bytes = password.encode('utf-8')
        print(pwd_bytes)
        return bcrypt.hashpw(pwd_bytes, salt)
    
    def validate_password(self, password: str, hashed_password: str) -> bool:
        return bcrypt.checkpw(password=password.encode(), hashed_password=hashed_password.encode())