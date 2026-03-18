import math


def circle_area(radius: float) -> dict:
    area = math.pi * radius**2
    circumference = 2 * math.pi * radius
    return {
        "area": round(area, 4),
        "circumference": round(circumference, 4),
    }


def triangle_area(base: float, height: float) -> dict:
    area = 0.5 * base * height
    return {"area": round(area, 4)}


def triangle_area_heron(a: float, b: float, c: float) -> dict:
    """Area via Heron's formula for triangle with sides a, b, c."""
    s = (a + b + c) / 2
    discriminant = s * (s - a) * (s - b) * (s - c)
    if discriminant < 0:
        return {"area": None, "error": "Invalid triangle sides"}
    area = math.sqrt(discriminant)
    return {"area": round(area, 4)}
