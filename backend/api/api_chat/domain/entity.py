from datetime import datetime
from dataclasses import dataclass


@dataclass
class MessageModel():
    msg_id: int
    chat_id: int
    sender_id: int
    text: str
    timestamp: str