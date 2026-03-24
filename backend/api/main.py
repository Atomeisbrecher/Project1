from dishka import make_async_container
from fastapi import FastAPI
from api_auth.presentation.routing import router as auth_router
import uvicorn
from dishka.integrations.fastapi import setup_dishka
from api_auth.presentation.ioc import AuthProvider



app = FastAPI(
    #title=settings.PROJECT_NAME
)

#app.add_middleware()
container = make_async_container(AuthProvider())
app.include_router(router=auth_router, prefix="/auth", tags=["auth"])
setup_dishka(container, app)
if __name__ == "__main__":
    uvicorn.run("main:app", reload = True)
