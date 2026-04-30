from pydantic import BaseModel


class MessageRequest(BaseModel):
    text: str
    reply_to_message_id: str | None = None