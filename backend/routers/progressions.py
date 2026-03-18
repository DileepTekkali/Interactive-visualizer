"""
Progressions API router — AP and GP computations, fully offline.
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services import progressions_service

router = APIRouter()


class APRequest(BaseModel):
    first: float = 1.0
    diff: float = 2.0
    count: int = 15


class GPRequest(BaseModel):
    first: float = 1.0
    ratio: float = 2.0
    count: int = 10


@router.post("/ap")
def get_ap(req: APRequest):
    if req.count < 1 or req.count > 200:
        raise HTTPException(status_code=400, detail="count must be between 1 and 200")
    return progressions_service.arithmetic_progression(req.first, req.diff, req.count)


@router.post("/gp")
def get_gp(req: GPRequest):
    if req.count < 1 or req.count > 100:
        raise HTTPException(status_code=400, detail="count must be between 1 and 100")
    if req.ratio == 0:
        raise HTTPException(status_code=400, detail="ratio cannot be 0")
    return progressions_service.geometric_progression(req.first, req.ratio, req.count)
