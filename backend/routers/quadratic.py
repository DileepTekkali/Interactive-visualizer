from fastapi import APIRouter
from pydantic import BaseModel
from services import quadratic_service

router = APIRouter()


class QuadraticRequest(BaseModel):
    a: float = 1.0
    b: float = 0.0
    c: float = 0.0
    x_min: float = -10.0
    x_max: float = 10.0


@router.post("/points")
def get_quadratic_points(req: QuadraticRequest):
    points = quadratic_service.compute_points(req.a, req.b, req.c, (req.x_min, req.x_max))
    vertex = quadratic_service.compute_vertex(req.a, req.b, req.c)
    roots = quadratic_service.compute_roots(req.a, req.b, req.c)
    equation = quadratic_service.build_equation_string(req.a, req.b, req.c)
    return {"points": points, "vertex": vertex, "roots": roots, "equation": equation}
