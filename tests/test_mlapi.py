import pytest
from fastapi.testclient import TestClient
from fastapi_cache import FastAPICache
from fastapi_cache.backends.inmemory import InMemoryBackend
from numpy.testing import assert_almost_equal

from src.main import app


@pytest.fixture
def client():
    FastAPICache.init(InMemoryBackend())
    with TestClient(app) as c:
        yield c

def test_predict_valid_input(client):
    data = {"text": ["I hate you.", "I love you."]}
    response = client.post(
        "/project-predict",
        json=data,
    )
    print(response.json())
    assert response.status_code == 200
    assert isinstance(response.json()["predictions"], list)
    assert isinstance(response.json()["predictions"][0], list)
    assert isinstance(response.json()["predictions"][0][0], dict)
    assert isinstance(response.json()["predictions"][1][0], dict)
    assert set(response.json()["predictions"][0][0].keys()) == {"label", "score"}
    assert set(response.json()["predictions"][0][1].keys()) == {"label", "score"}
    assert set(response.json()["predictions"][1][0].keys()) == {"label", "score"}
    assert set(response.json()["predictions"][1][1].keys()) == {"label", "score"}
    assert response.json()["predictions"][0][0]["label"] == "NEGATIVE"
    assert response.json()["predictions"][0][1]["label"] == "POSITIVE"
    assert response.json()["predictions"][1][0]["label"] == "POSITIVE"
    assert response.json()["predictions"][1][1]["label"] == "NEGATIVE"
    assert (
        assert_almost_equal(
            response.json()["predictions"][0][0]["score"], 0.936, decimal=1
        )
        is None
    )
    assert (
        assert_almost_equal(
            response.json()["predictions"][0][1]["score"], 0.064, decimal=1
        )
        is None
    )
    assert (
        assert_almost_equal(
            response.json()["predictions"][1][0]["score"], 0.997, decimal=1
        )
        is None
    )
    assert (
        assert_almost_equal(
            response.json()["predictions"][1][1]["score"], 0.003, decimal=1
        )
        is None
    )

def test_predict_invalid_input(client):
    data = {"text": "This is not a list"}
    response = client.post("/project-predict", json=data)
    assert response.status_code == 422

def test_predict_invalid_input_2(client):
    data = {"text": [1, 3, 5]}
    response = client.post("/project-predict", json=data)
    assert response.status_code == 422
    
def test_root(client):
    """
    Tests the root endpoint
    """
    response = client.get("/")
    assert response.status_code == 404

def test_docs(client):
    """
    Tests the docs endpoint
    """
    response = client.get("/docs")
    assert response.status_code == 200

def test_openapi(client):
    """
    Tests the openapi.json endpoint and ensures the response is valid JSON
    """
    response = client.get("/openapi.json")
    assert response.status_code == 200
    assert isinstance(response.json(), dict)
