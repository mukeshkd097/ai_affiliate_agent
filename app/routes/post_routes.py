# Route to trigger posts
from fastapi import APIRouter

router = APIRouter()

@router.post("/post/{platform}")
def post_to_platform(platform: str, content: str):
    # Dummy function for now
    print(f"Posting to {platform}: {content}")
    return {"message": f"Posting to {platform} initiated"}