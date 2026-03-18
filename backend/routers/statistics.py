"""
Statistics API router — computes descriptive stats and histogram data offline.
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from services import statistics_service

router = APIRouter()


class DatasetRequest(BaseModel):
    values: List[float]
    bins: int = 10


class SampleRequest(BaseModel):
    mean: float = 50.0
    std: float = 10.0
    count: int = 100


@router.post("/stats")
def get_stats(req: DatasetRequest):
    if not req.values:
        raise HTTPException(status_code=400, detail="values list cannot be empty")
    return statistics_service.compute_stats(req.values)


@router.post("/histogram")
def get_histogram(req: DatasetRequest):
    if not req.values:
        raise HTTPException(status_code=400, detail="values list cannot be empty")
    return statistics_service.compute_histogram(req.values, req.bins)


@router.post("/sample/normal")
def get_normal_sample(req: SampleRequest):
    samples = statistics_service.generate_normal_sample(req.mean, req.std, req.count)
    stats = statistics_service.compute_stats(samples)
    histogram = statistics_service.compute_histogram(samples, 10)
    return {"samples": samples, "stats": stats, "histogram": histogram}
