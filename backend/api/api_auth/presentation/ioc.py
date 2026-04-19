from typing import AsyncGenerator, AsyncIterable
import logging

from dishka import Provider, Scope, provide
from opentelemetry import trace
from api_auth.domain.interfaces import IPasswordHasher, ITokenAuth, ITokenProvider, ITokenStorage, IUnitOfWork, IUserRepository
from api_auth.infrastructure.db.cache_redis.redis_token_storage import RedisTokenStorage
from api_auth.infrastructure.db.postgres.unit_of_work import SQLAlchemyUnitOfWork
from api_auth.application.interactors.login import LoginUseCase
from api_auth.infrastructure.services.password_hasher.password_hasher import BCryptPasswordHash
from api_auth.application.interactors.exchange_code_for_token import ExchangeCodeForToken
from api_auth.infrastructure.services.jwt.jwt_service import TokenProvider, TokenAuth
from api_auth.application.interactors.register import RegisterUser

from redis.asyncio import Redis
import redis.asyncio as redis
from auth_config import settings, Settings
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, async_sessionmaker, create_async_engine

from api_auth.infrastructure.db.postgres.user_repository import PGUserRepository
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor

logger = logging.getLogger(__name__)

class AuthProvider(Provider):
    @provide(scope=Scope.APP)
    def config(self) -> Settings:
        logger.debug("Initializing AuthProvider...")
        return settings

    @provide(scope=Scope.APP)
    async def get_redis(self, cfg: Settings) -> redis.Redis:
        logger.debug("Initializing Redis connection...")
        return redis.from_url(cfg.redis.REDIS_URL, decode_responses=True)

    
    @provide(scope=Scope.APP)
    def hasher(self) -> IPasswordHasher:
        logger.debug("Creating Password Hasher...")
        return BCryptPasswordHash()
    
    @provide(scope=Scope.APP)
    def engine(self) -> AsyncEngine:
        logger.debug("Creating async engine for database...")
        engine = create_async_engine(
            settings.db.DB_URL,
            echo = settings.db.ECHO,
            echo_pool = settings.db.ECHO_POOL,
            pool_pre_ping = settings.db.POOL_PRE_PING,
            pool_size = settings.db.POOL_SIZE, 
        )
    
        SQLAlchemyInstrumentor().instrument(
            engine=engine.sync_engine,
            tracer_provider=trace.get_tracer_provider(),
            enable_commenter=True,
            commenter_options={
                "db_driver": True,
                "db_framework": True,
                "opentelemetry_values": True,
            }
        )
        return engine
    
    @provide(scope=Scope.APP)
    def session_factory(self, engine: AsyncEngine) -> async_sessionmaker:
        logger.debug("Creating session factory...")
        return async_sessionmaker(engine, expire_on_commit=False)

    @provide(scope=Scope.REQUEST)
    async def session(self, session_factory: async_sessionmaker) -> AsyncGenerator[AsyncSession, None]:
        logger.debug("Getting database session from pool...")
        async with session_factory as session:
            logger.debug("Database session obtained")
            yield session
            logger.debug("Session closed")

    @provide(scope=Scope.REQUEST)
    async def user_repo(self, session: AsyncSession) -> AsyncIterable[IUserRepository]:
        yield PGUserRepository(session)
    
    @provide(scope=Scope.REQUEST)
    async def uow(self, session: async_sessionmaker) -> AsyncIterable[IUnitOfWork]:
        async with session() as session:
            logger.debug("Creating Unit of Work...")
            yield SQLAlchemyUnitOfWork(session)


    @provide(scope=Scope.REQUEST)
    def redis_storage(self, r: redis.Redis, token_provider: ITokenProvider) -> ITokenStorage:
        logger.debug("Creating Redis Token Storage...")
        return RedisTokenStorage(r, token_provider)

    @provide(scope=Scope.REQUEST)
    def login_uc(self, uow: IUnitOfWork, s: ITokenStorage, hasher: IPasswordHasher) -> LoginUseCase:
        logger.debug("Creating Login Use Case...")
        return LoginUseCase(uow, s, hasher)
    
    @provide(scope=Scope.REQUEST)
    def register_cmd(self, hasher: IPasswordHasher, uow: IUnitOfWork) -> RegisterUser:
        logger.debug("Creating Register Use Case...")
        return RegisterUser(hasher, uow)
    
    @provide(scope=Scope.SESSION)
    def token_provider(self) -> ITokenProvider:
        logger.debug("Creating Token Provider...")
        return TokenProvider()
    
    @provide(scope=Scope.REQUEST)
    def token_auth(self,
                       provider: ITokenProvider,
                       storage: ITokenStorage
                       ) -> ITokenAuth:
        logger.debug("Creating Token Auth...")
        return TokenAuth(token_provider=provider, token_storage=storage)

    @provide(scope=Scope.REQUEST)
    def exchange_use_case(self, s: ITokenStorage, t: ITokenAuth) -> ExchangeCodeForToken:
        logger.debug("Creating Exchange Code For Token Use Case...")
        return ExchangeCodeForToken(s, t)
