import logging

from fastapi import FastAPI
from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_cache.decorator import cache
from pydantic import BaseModel, Field
from typing import List
from redis import asyncio as aioredis
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

model_path = "./distilbert-base-uncased-finetuned-sst2"
model = AutoModelForSequenceClassification.from_pretrained(model_path)
tokenizer = AutoTokenizer.from_pretrained(model_path)
classifier = pipeline(
    task="text-classification",
    model=model,
    tokenizer=tokenizer,
    device=-1,
    top_k=None,
)

logger = logging.getLogger(__name__)
  
app = FastAPI()

@app.on_event("startup")
async def startup():
    redis_host = "redis"
    redis_port = 6379
    redis_url = f"redis://{redis_host}:{redis_port}"
    redis = aioredis.from_url(redis_url)
    FastAPICache.init(RedisBackend(redis), prefix="fastapi-cache")

class SentimentRequest(BaseModel):
    text: List[str] = Field(..., json_schema_extra={"example": ["example 1", "example 2"]})

class Sentiment(BaseModel):
    label: str = Field(..., json_schema_extra={"example": "POSITIVE"})
    score: float = Field(..., json_schema_extra={"example": 0.9999})

class SentimentResponse(BaseModel):
    predictions: List[List[Sentiment]] = Field(
        ..., 
        json_schema_extra={"example": [
            [{"label": "POSITIVE", "score": 0.9999}, {"label": "NEGATIVE", "score": 0.0001}],
            [{"label": "NEGATIVE", "score": 0.0001}, {"label": "POSITIVE", "score": 0.9999}]
        ]}
    )

@app.post("/project-predict", response_model=SentimentResponse)
@cache(expire=60)
async def predict(sentiments: SentimentRequest):
    return {"predictions": classifier(sentiments.text)}

@app.get("/health")
async def health():
    return {"status": "healthy"}
