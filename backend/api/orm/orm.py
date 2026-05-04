from datetime import datetime
from typing import List, Optional
from enum import Enum as PyEnum
from sqlalchemy import BigInteger, ForeignKey, PrimaryKeyConstraint, String, func, Enum
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import JSONB

class ChatType(PyEnum):
    DIRECT = "direct"
    GROUP = "group"

class Base(DeclarativeBase):
    pass

class UserORM(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    email: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    phone: Mapped[Optional[str]] = mapped_column(String(15), unique=True, index=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    pwdhash: Mapped[str] = mapped_column(String(255), nullable=False)
    pts: Mapped[int] = mapped_column(BigInteger, server_default="0")

class ChatORM(Base):
    __tablename__ = "chats"
    
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)

    type: Mapped[ChatType] = mapped_column(
        Enum(ChatType, native_enum=False), 
        server_default=ChatType.DIRECT.value
    )

    unique_tag: Mapped[Optional[str]] = mapped_column(String(64), unique=True)
    last_message_id: Mapped[int] = mapped_column(BigInteger, server_default="0")
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())

    messages: Mapped[List["MessageORM"]] = relationship(back_populates="chat", cascade="all, delete-orphan")
    members: Mapped[List["ChatMemberORM"]] = relationship(back_populates="chat")

class ChatMemberORM(Base):
    __tablename__ = "chat_members"

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    chat_id: Mapped[int] = mapped_column(ForeignKey("chats.id", ondelete="CASCADE"), primary_key=True)
    
    role: Mapped[str] = mapped_column(String(20), server_default="member")
    last_read_message_id: Mapped[int] = mapped_column(BigInteger, server_default="0")
    joined_at: Mapped[datetime] = mapped_column(server_default=func.now())

    chat: Mapped["ChatORM"] = relationship(back_populates="members")

class MessageORM(Base):
    __tablename__ = "messages"

    chat_id: Mapped[int] = mapped_column(ForeignKey("chats.id", ondelete="CASCADE"), primary_key=True)
    message_id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    
    sender_id: Mapped[int] = mapped_column(BigInteger, index=True)
    text: Mapped[Optional[str]] = mapped_column(String(4096))

    attachments: Mapped[Optional[dict]] = mapped_column(JSONB, server_default="{}") #metadata
    created_at: Mapped[datetime] = mapped_column(server_default=func.now(), index=True)
    
    chat: Mapped["ChatORM"] = relationship(back_populates="messages")