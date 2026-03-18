from fastapi import APIRouter
from pydantic import BaseModel
from services import linear_service

router = APIRouter()


class LinearRequest(BaseModel):
    m: float = 1.0
    c: float = 0.0
    x_min: float = -10.0
    x_max: float = 10.0


@router.post("/points")
def get_linear_points(req: LinearRequest):
    points = linear_service.compute_points(req.m, req.c, (req.x_min, req.x_max))
    intercepts = linear_service.compute_intercepts(req.m, req.c)
    equation = linear_service.build_equation_string(req.m, req.c)
    return {"points": points, "intercepts": intercepts, "equation": equation}
