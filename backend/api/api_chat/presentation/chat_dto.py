from typing import Optional
from pydantic import BaseModel


class MessageRequest(BaseModel):
    text: str
    reply_to_message_id: Optional[str] = None