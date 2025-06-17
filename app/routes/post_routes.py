# Route to trigger posts
from fastapi import APIRouter
from ..services import amazon
from ..services import content_gen

router = APIRouter()

@router.post("/post/{platform}")
def post_to_platform(platform: str, content: str):
    # Dummy function for now
    print(f"Posting to {platform}: {content}")
    return {"message": f"Posting to {platform} initiated"}

@router.post("/post/amazon/{platform}")
async def post_amazon_product_to_platform(platform: str):
    product = amazon.get_mock_product()
    caption = content_gen.generate_caption(product)
    # Simulate calling the other post function or its logic
    # For now, we'll just confirm the action.
    # The actual call to another platform post is not made here yet.
    return {
        "message": f"Amazon product '{product['title']}' caption generated and prepared for posting to {platform}",
        "product_title": product['title'],
        "caption": caption,
        "platform": platform
    }