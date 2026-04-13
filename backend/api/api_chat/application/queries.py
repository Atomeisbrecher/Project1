from sqlalchemy import select

from api_chat.domain.entity import MessageModel

class GetChatHistoryQuery:
    def __init__(self, session_factory):
        self.session_factory = session_factory

    async def execute(self, chat_id: str, limit: int = 50, offset: int = 0):
        async with self.session_factory() as session:
            stmt = (
                select(MessageModel)
                .where(MessageModel.chat_id == chat_id)
                .order_by(MessageModel.created_at.desc())
                .limit(limit)
                .offset(offset)
            )
            result = await session.execute(stmt)
            return result.scalars().all()
        
class SyncMessagesCommand:
    def __init__(self, session_factory):
        self.session_factory = session_factory

    async def execute(self, chat_id: str, last_message_id: int | None = None):
        async with self.session_factory() as session:
            stmt = (
                select(MessageModel)
                .where(MessageModel.chat_id == chat_id)
                .order_by(MessageModel.created_at.desc())
            )
            if last_message_id is not None:
                stmt = stmt.where(MessageModel.id > last_message_id)
            result = await session.execute(stmt)
            return result.scalars().all()
        
#NOTE Это всё тупые ИИ-наброски, в данный момент даже неприменимы.