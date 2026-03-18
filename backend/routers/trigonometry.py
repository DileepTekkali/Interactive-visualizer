"""
Trigonometry API router — computes waveforms and unit circle values offline.
"""
from fastapi import APIRouter
from pydantic import BaseModel
from services import trigonometry_service

router = APIRouter()


class WaveRequest(BaseModel):
    func: str = "sin"           # sin | cos | tan
    amplitude: float = 1.0
    frequency: float = 1.0
    phase: float = 0.0
    x_min: float = -6.3
    x_max: float = 6.3


@router.post("/wave")
def get_wave(req: WaveRequest):
    return trigonometry_service.compute_wave(
        req.func, req.amplitude, req.frequency, req.phase, req.x_min, req.x_max
    )


@router.get("/unit-circle")
def get_unit_circle_point(angle: float = 0.0):
    return trigonometry_service.compute_unit_circle_point(angle)
