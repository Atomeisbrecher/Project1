from datetime import datetime
from sqlalchemy import BigInteger, ForeignKey, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship

class Base(DeclarativeBase):
    pass

class ChatORM(Base):
    __tablename__ = "chats"
    
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    
    messages: Mapped[list["MessageORM"]] = relationship(back_populates="chat")

class MessageORM(Base):
    __tablename__ = "messages"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    chat_id: Mapped[int] = mapped_column(ForeignKey("chats.id"), index=True)
    sender_id: Mapped[int] = mapped_column(BigInteger, index=True)
    text: Mapped[str]
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())

    chat: Mapped["ChatORM"] = relationship(back_populates="messages")