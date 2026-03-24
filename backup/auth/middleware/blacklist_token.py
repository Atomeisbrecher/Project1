import redis

# Подключение к Redis
r = redis.Redis(host='localhost', port=6379, db=0)

# При выходе пользователя (Logout):
# Заносим токен в blacklist до истечения его срока жизни
def blacklist_token(token: str, ttl_seconds: int):
    r.setex(f"blacklist:{token}", ttl_seconds, "true")

# В middleware для проверки токена:
def is_token_blacklisted(token: str) -> bool:
    return r.exists(f"blacklist:{token}") == 1