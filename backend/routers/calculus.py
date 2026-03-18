"""
Calculus API router — computes function/derivative/integral entirely offline.
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services import calculus_service

router = APIRouter()


class CalcRequest(BaseModel):
    func_type: str = "polynomial"  # polynomial | sine | exponential
    param: float = 1.0
    x_min: float = -5.0
    x_max: float = 5.0


@router.post("/compute")
def compute_calculus(req: CalcRequest):
    if req.func_type not in ("polynomial", "sine", "exponential"):
        raise HTTPException(status_code=400, detail="func_type must be polynomial, sine, or exponential")
    return calculus_service.compute_function(req.func_type, req.x_min, req.x_max, req.param)
