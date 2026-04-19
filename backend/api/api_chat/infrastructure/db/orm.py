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



# chat_members = Table(
#     "chat_members",
#     Base.metadata,
#     Column("user_id", ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
#     Column("chat_id", ForeignKey("chats.id", ondelete="CASCADE"), primary_key=True),
# )

# class MessageType(str, Enum):
#     TEXT = "text"
#     REPLY = "reply"
#     FORWARDED = "forwarded"

# class User(Base):
#     __tablename__ = "users"
    
#     id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
#     username: Mapped[str] = mapped_column(String(255), unique=True)
#     first_name: Mapped[str] = mapped_column(String(255))
#     last_name: Mapped[Optional[str]] = mapped_column(String(255))
#     email: Mapped[str] = mapped_column(String(255), unique=True)
#     phone: Mapped[Optional[str]] = mapped_column(String(20))
#     last_seen: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
#     chats: Mapped[List["Chat"]] = relationship(
#         secondary=chat_members, back_populates="members"
#     )

# class Chat(Base):
#     __tablename__ = "chats"
    
#     id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
#     created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
#     members: Mapped[List["User"]] = relationship(
#         secondary=chat_members, back_populates="chats"
#     )
#     messages: Mapped[List["Message"]] = relationship(back_populates="chat")

# class Message(Base):
#     __tablename__ = "messages"
    
#     id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
#     chat_id: Mapped[int] = mapped_column(ForeignKey("chats.id", ondelete="CASCADE"))
#     sender_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    
#     # Тип сообщения
#     msg_type: Mapped[MessageType] = mapped_column(String, default=MessageType.TEXT)
#     # Если это reply, храним ID родительского сообщения
#     reply_to_id: Mapped[Optional[int]] = mapped_column(ForeignKey("messages.id"))
    
#     text: Mapped[str] = mapped_column(String)
#     created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)
#     # Если read_at IS NULL — сообщение не прочитано
#     read_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)

#     chat: Mapped["Chat"] = relationship(back_populates="messages")