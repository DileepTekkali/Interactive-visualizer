from fastapi import APIRouter
from pydantic import BaseModel
from services import geometry_service

router = APIRouter()


class CircleRequest(BaseModel):
    radius: float = 5.0


class TriangleRequest(BaseModel):
    base: float = 6.0
    height: float = 4.0


class HeroTriangleRequest(BaseModel):
    a: float = 3.0
    b: float = 4.0
    c: float = 5.0


@router.post("/circle")
def get_circle(req: CircleRequest):
    return geometry_service.circle_area(req.radius)


@router.post("/triangle")
def get_triangle(req: TriangleRequest):
    return geometry_service.triangle_area(req.base, req.height)


@router.post("/triangle/heron")
def get_triangle_heron(req: HeroTriangleRequest):
    return geometry_service.triangle_area_heron(req.a, req.b, req.c)
