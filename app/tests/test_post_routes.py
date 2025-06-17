from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_post_to_platform_success():
    platform_name = "test_platform"
    response = client.post(f"/post/{platform_name}")
    assert response.status_code == 200
    assert response.json() == {"message": f"Posting to {platform_name} initiated"}

def test_post_amazon_product_to_platform():
    platform_name = "test_social_platform"
    response = client.post(f"/post/amazon/{platform_name}")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == f"Amazon product 'Cool Gadget' caption generated and prepared for posting to {platform_name}"
    assert data["product_title"] == "Cool Gadget"
    assert "caption" in data
    assert data["caption"] == "Check out this Cool Gadget! #deals"
    assert data["platform"] == platform_name

def test_post_to_different_platform_success():
    platform_name = "another_platform"
    response = client.post(f"/post/{platform_name}")
    assert response.status_code == 200
    assert response.json() == {"message": f"Posting to {platform_name} initiated"}
