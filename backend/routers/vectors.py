"""
Vectors API router — 2D/3D vector computations, fully offline.
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from services import vectors_service

router = APIRouter()


class VectorRequest(BaseModel):
    v1: List[float]
    v2: List[float]


@router.post("/compute")
def compute_vectors(req: VectorRequest):
    if not req.v1 or not req.v2:
        raise HTTPException(status_code=400, detail="Both vectors must be non-empty.")
    result = vectors_service.vector_operations(req.v1, req.v2)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    return result
