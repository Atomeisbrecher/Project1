from typing import AsyncIterable

from dishka import Provider, Scope, provide
from api_auth.domain.interfaces import IPasswordHasher, ITokenAuth, ITokenProvider, ITokenStorage, IUnitOfWork, IUserRepository
from api_auth.infrastructure.db.postgres.session import DbManager
from api_auth.infrastructure.db.cache_redis.cache_redis import RedisTokenStorage
from api_auth.infrastructure.db.postgres.unit_of_work import SQLAlchemyUnitOfWork
from api_auth.application.interactors.login import LoginUseCase
from api_auth.infrastructure.services.password_hasher.password_hasher import BCryptPasswordHash
from api_auth.application.interactors.exchange_code_for_token import ExchangeCodeForToken
from api_auth.infrastructure.services.jwt.jwt_service import TokenProvider, TokenAuth
from api_auth.application.interactors.register import RegisterUser
from api_auth.infrastructure.db.postgres.user_repository import PGUserRepository
from redis.asyncio import Redis
import redis.asyncio as redis
from auth_config import settings, Settings


class AuthProvider(Provider):
    @provide(scope=Scope.APP)
    def get_config(self) -> Settings: return settings

    @provide(scope=Scope.APP)
    def get_db_manager(self, cfg: Settings) -> DbManager: return DbManager(cfg.db.DB_URL)

    @provide(scope=Scope.APP)
    def get_redis(self, cfg: Settings) -> redis.Redis: 
        return redis.from_url(cfg.redis.REDIS_URL, decode_responses=True)

    @provide(scope=Scope.REQUEST)
    async def get_uow(self, db: DbManager) -> AsyncIterable[IUnitOfWork]:
        async for session in db.get_session():
            yield SQLAlchemyUnitOfWork(session)

    @provide(scope=Scope.APP)
    def get_hasher(self) -> IPasswordHasher:
        return BCryptPasswordHash()
    
    @provide(scope=Scope.APP)
    async def get_repo(self, db: DbManager) -> AsyncIterable[IUserRepository]:
        async for session in db.get_session():
            yield PGUserRepository(session)

    @provide(scope=Scope.REQUEST)
    def get_redis_storage(self, r: redis.Redis = redis.Redis) -> ITokenStorage: return RedisTokenStorage(r)

    @provide(scope=Scope.REQUEST)
    def get_login_uc(self, uow: IUnitOfWork, s: ITokenStorage, hasher: IPasswordHasher) -> LoginUseCase:
        return LoginUseCase(uow, s, hasher)
    
    @provide(scope=Scope.REQUEST)
    def get_register_cmd(self, repo: IUserRepository, hasher: IPasswordHasher) -> RegisterUser:
        return RegisterUser(repo, hasher)
    
    @provide(scope=Scope.APP)
    def get_token_provider(self) -> ITokenProvider:
        return TokenProvider()
    
    @provide(scope=Scope.REQUEST)
    def get_token_auth(self,
                       provider: ITokenProvider,
                       storage: ITokenStorage
                       ) -> ITokenAuth:
        return TokenAuth(token_provider=provider, token_storage=storage)

    @provide(scope=Scope.REQUEST)
    def get_exchange_use_case(self, s: ITokenStorage, t: ITokenAuth) -> ExchangeCodeForToken:
        return ExchangeCodeForToken(s, t)
