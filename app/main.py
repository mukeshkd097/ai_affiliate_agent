# FastAPI main entry point
from fastapi import FastAPI
from .routes import post_routes
app = FastAPI()
app.include_router(post_routes.router)

@app.get('/')
def read_root():
    return {"status": "AI Affiliate Agent Running"}