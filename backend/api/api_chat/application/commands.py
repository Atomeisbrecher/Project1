from select import select


from api_chat.domain.entity import MessageModel


class SendMessageCommand:
    def __init__(self, session_factory):
        self.session_factory = session_factory

    async def execute(self, sender_id: int, chat_id: str, text: str):
        async with self.session_factory() as session:
            new_message = MessageModel(
                sender_id=sender_id,
                chat_id=chat_id,
                text=text
            )
            session.add(new_message)
            await session.commit()