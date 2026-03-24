



async def authenticate(
        email: str,
        password: str,
        pwd_hasher: str,
        uow: IUserUnitOfWork,
        auth: ITokenAuth,
) -> User:
    
    async with uow:
        user = await uow.users.get_by_email(email)
    
    if not pwd_hasher.verify(password, user.hashed_password):
        raise InvalidCredential()
    
    await auth.set_token(user)
    return user