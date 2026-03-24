from pathlib import Path
from pydantic import BaseModel, Field
from sqlalchemy import URL
from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).parent

class DbSettings(BaseSettings):
    DB_USER: str = Field(alias="DB_USER")
    DB_PASS: str = Field(alias="DB_PASS")
    DB_NAME: str = Field(alias="DB_NAME")
    DB_DRIVER: str = Field(alias="DB_DRIVER")
    DB_HOST: str = Field(alias="DB_HOST")
    DB_PORT: int = Field(alias="DB_PORT")

    model_config = SettingsConfigDict(
        env_file=".env", 
        env_file_encoding="utf-8",
        extra = "ignore"
    )
    
    @property
    def DB_URL(self) -> str:
        return URL.create(
            drivername=self.DB_DRIVER,
            database=self.DB_NAME,
            host=self.DB_HOST,
            port=self.DB_PORT,
            username=self.DB_USER,
            password=self.DB_PASS,
        ).render_as_string(hide_password=False)
    #f"postgresql+asyncpg://my_admin:super_secret_db_pass@localhost/app_db"


class RedisSettings(BaseSettings):
    REDIS_HOST: str = Field(alias="REDIS_HOST")
    REDIS_PORT: int = Field(alias="REDIS_PORT")
    REDIS_PASS: str = Field(alias="REDIS_PASS")
    

    model_config = SettingsConfigDict(
        env_file=".env", 
        env_file_encoding="utf-8",
        extra = "ignore"
    )
    @property
    def REDIS_URL(self) -> str:
        # Формат: redis://[:password]@host:port/db
        return f"redis://:{self.REDIS_PASS}@{self.REDIS_HOST}:{self.REDIS_PORT}"

class AuthJWT(BaseSettings):
    private_key_path: Path = BASE_DIR / "certs" / "jwt-private.pem"
    public_key_path: Path = BASE_DIR / "certs" / "jwt-public.pem"
    algorithm: str = "RS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 14


class Settings(BaseSettings):
    redis: RedisSettings = RedisSettings()
    db: DbSettings = DbSettings()
    auth_jwt: AuthJWT = AuthJWT()


settings = Settings()
