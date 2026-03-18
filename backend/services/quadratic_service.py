"""
Quadratic equation service — 100% offline using only Python stdlib + numpy.
"""
import numpy as np
import math


def compute_points(a: float, b: float, c: float, x_range: tuple) -> list:
    """Return {x, y} points for y = ax² + bx + c."""
    xs = np.linspace(x_range[0], x_range[1], 300)
    ys = a * xs**2 + b * xs + c
    return [{"x": round(float(xi), 4), "y": round(float(yi), 4)} for xi, yi in zip(xs, ys)]


def compute_vertex(a: float, b: float, c: float) -> dict:
    """Return the vertex of the parabola."""
    if a == 0:
        return {"x": None, "y": None}
    vx = -b / (2 * a)
    vy = a * vx**2 + b * vx + c
    return {"x": round(vx, 4), "y": round(vy, 4)}


def compute_roots(a: float, b: float, c: float) -> list:
    """Return real roots of ax² + bx + c = 0."""
    if a == 0:
        return [round(-c / b, 4)] if b != 0 else []
    discriminant = b**2 - 4 * a * c
    if discriminant < 0:
        return []
    if discriminant == 0:
        return [round(-b / (2 * a), 4)]
    sqrt_d = math.sqrt(discriminant)
    return [round((-b + sqrt_d) / (2 * a), 4), round((-b - sqrt_d) / (2 * a), 4)]


def build_equation_string(a: float, b: float, c: float) -> str:
    """Build a human-readable quadratic equation (no sympy needed)."""
    def fmt(v):
        return str(int(v)) if v == int(v) else f"{v:.2f}".rstrip("0").rstrip(".")

    parts = []
    if a != 0:
        cf = f"{fmt(abs(a))}x²" if abs(a) != 1 else "x²"
        parts.append(f"-{cf}" if a < 0 else cf)
    if b != 0:
        cf = f"{fmt(abs(b))}x" if abs(b) != 1 else "x"
        parts.append(f"- {cf}" if b < 0 else f"+ {cf}")
    if c != 0:
        parts.append(f"- {fmt(abs(c))}" if c < 0 else f"+ {fmt(abs(c))}")
    return "y = " + " ".join(parts) if parts else "y = 0"
