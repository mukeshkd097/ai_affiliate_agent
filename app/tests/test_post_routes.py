from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_post_to_platform_success():
    platform_name = "test_platform"
    response = client.post(f"/post/{platform_name}")
    assert response.status_code == 200
    assert response.json() == {"message": f"Posting to {platform_name} initiated"}

def test_post_to_different_platform_success():
    platform_name = "another_platform"
    response = client.post(f"/post/{platform_name}")
    assert response.status_code == 200
    assert response.json() == {"message": f"Posting to {platform_name} initiated"}
