from typing import AsyncGenerator, AsyncIterable
import logging

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

from redis.asyncio import Redis
import redis.asyncio as redis
from auth_config import settings, Settings
from sqlalchemy.ext.asyncio import AsyncSession

from api_auth.infrastructure.db.postgres import session
from api_auth.infrastructure.db.postgres.user_repository import PGUserRepository

logger = logging.getLogger(__name__)

class AuthProvider(Provider):
    @provide(scope=Scope.APP)
    def get_config(self) -> Settings:
        logger.debug("Initializing AuthProvider...")
        return settings

    @provide(scope=Scope.APP)
    def get_redis(self, cfg: Settings) -> redis.Redis:
        logger.debug("Initializing Redis connection...")
        return redis.from_url(cfg.redis.REDIS_URL, decode_responses=True)

    @provide(scope=Scope.APP)
    def get_db_manager(self, cfg: Settings) -> DbManager:
        logger.debug("Creating DbManager...")
        manager = DbManager(cfg.db.DB_URL)
        logger.info("Database manager initialized successfully")
        return manager

    @provide(scope=Scope.REQUEST)
    async def get_session(self, db: DbManager) -> AsyncGenerator[AsyncSession, None]:
        logger.debug("Getting database session from pool...")
        async with db.session_factory() as session:
            logger.debug("Database session obtained")
            yield session
            logger.debug("Session closed")

    @provide(scope=Scope.REQUEST)
    def get_user_repo(self, session: AsyncSession) -> IUserRepository:
        return PGUserRepository(session)
    
    @provide(scope=Scope.REQUEST)
    def get_uow(self, session: AsyncSession, repo: IUserRepository) -> IUnitOfWork:
        logger.debug("Creating Unit of Work...")
        return SQLAlchemyUnitOfWork(session, repo)
    
    @provide(scope=Scope.REQUEST)
    def get_hasher(self) -> IPasswordHasher:
        logger.debug("Creating Password Hasher...")
        return BCryptPasswordHash()
    

    @provide(scope=Scope.REQUEST)
    def get_redis_storage(self, r: redis.Redis) -> ITokenStorage:
        logger.debug("Creating Redis Token Storage...")
        return RedisTokenStorage(r)

    @provide(scope=Scope.REQUEST)
    def get_login_uc(self, uow: IUnitOfWork, s: ITokenStorage, hasher: IPasswordHasher) -> LoginUseCase:
        logger.debug("Creating Login Use Case...")
        return LoginUseCase(uow, s, hasher)
    
    @provide(scope=Scope.REQUEST)
    def get_register_cmd(self, hasher: IPasswordHasher, uow: IUnitOfWork) -> RegisterUser:
        logger.debug("Creating Register Use Case...")
        return RegisterUser(hasher, uow)
    
    @provide(scope=Scope.REQUEST)
    def get_token_provider(self) -> ITokenProvider:
        logger.debug("Creating Token Provider...")
        return TokenProvider()
    
    @provide(scope=Scope.REQUEST)
    def get_token_auth(self,
                       provider: ITokenProvider,
                       storage: ITokenStorage
                       ) -> ITokenAuth:
        logger.debug("Creating Token Auth...")
        return TokenAuth(token_provider=provider, token_storage=storage)

    @provide(scope=Scope.REQUEST)
    def get_exchange_use_case(self, s: ITokenStorage, t: ITokenAuth) -> ExchangeCodeForToken:
        logger.debug("Creating Exchange Code For Token Use Case...")
        return ExchangeCodeForToken(s, t)
