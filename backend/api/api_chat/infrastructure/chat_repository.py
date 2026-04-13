from api_chat.infrastructure.orm import MessageORM



class ChatRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def save_message(self, chat_id: int, sender_id: int, text: str) -> MessageORM:
        new_msg = MessageORM(chat_id=chat_id, sender_id=sender_id, text=text)
        self.session.add(new_msg)
        await self.session.flush()  # Получаем ID из БД без завершения транзакции
        return new_msg

    async def get_chat_participants(self, chat_id: int) -> list[int]:
        # Логика получения ID участников чата для рассылки
        # В реальной схеме здесь была бы таблица-связка UserChat
        return [123, 456]