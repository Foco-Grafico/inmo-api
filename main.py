from src.core.app import FAST_APP
from src.auth.router import router as auth_router

fast_app = FAST_APP(
    routers=[
        auth_router
    ]
)

app = fast_app.get_app()

@app.get("/")
async def root():
    return {"message": 'Hello World!'}

@app.get('/health')
async def health():
    return 'OK'

