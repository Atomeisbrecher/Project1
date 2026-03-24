# from api_auth.domain.interfaces import ITokenStorage

# class InMemoryAuthRepo(ITokenStorage):
#     def __init__(self):
#         self._codes = {}

#     async def save_code(self, code_data: AuthCode):
#         self._codes[code_data.code] = code_data

#     async def get_and_delete_code(self, code: str) -> AuthCode | None:
#         return self._codes.pop(code, None)