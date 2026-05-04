from datetime import datetime
from dataclasses import dataclass


@dataclass
class MessageModel():
    chat_id: int
    message_id: int
    sender_id: int
    text: str
    attachments: str
    timestamp: str