from orm.orm import MessageORM
from sqlalchemy.ext.asyncio import AsyncSession

# NOTE: Репозиторий для работы с постоянным хранилищем данных
class ChatRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def save_message(self, chat_id: int, sender_id: int, text: str) -> MessageORM:
        new_msg = MessageORM(chat_id=chat_id, sender_id=sender_id, text=text)
        self.session.add(new_msg)
        await self.session.flush()
        return new_msg

    async def get_chat_participants_ids(self, chat_id: int) -> list[int]:
        return [123, 456]