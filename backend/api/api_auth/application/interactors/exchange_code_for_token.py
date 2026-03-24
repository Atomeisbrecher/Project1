import base64
import hashlib

from api_auth.domain.interfaces import ITokenAuth, ITokenStorage


class ExchangeCodeForToken():
    def __init__(
            self,
            storage: ITokenStorage,
            token_service: ITokenAuth,
    ):
        self.storage = storage
        self.token_service = token_service

    async def execute(self, code: str, code_verifier: str) -> dict:
        code_data = await self.storage.get_and_delete_code(code)
        if not code_data:
            raise ValueError("Invalid or expired code")
        
        if not self._verify_pkce(code_verifier, code_data.challenge):
            raise ValueError("PKCE validation failed")
        print(code_data)
        return await self.token_service.set_tokens(code_data.user_id)
    
    def _verify_pkce(self, verifier: str, challenge: str) -> bool:
        digest = hashlib.sha256(verifier.encode('utf-8')).digest()
        expected = base64.urlsafe_b64encode(digest).decode('utf-8').rstrip('=')
        return challenge == expected
    