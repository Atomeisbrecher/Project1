from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

class DbManager:
    def __init__(self, url: str, echo: bool = False):
        self.engine = create_async_engine(url, echo=echo)
        self.session_factory = async_sessionmaker(
            bind=self.engine, 
            expire_on_commit=False,
            class_=AsyncSession
        )

    async def get_session(self):
        async with self.session_factory() as session:
            yield session