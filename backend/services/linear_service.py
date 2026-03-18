"""
Linear equation service — 100% offline using only Python stdlib + numpy.
"""
import numpy as np


def compute_points(m: float, c: float, x_range: tuple) -> list:
    """Return a list of {x, y} points for y = mx + c over the given range."""
    xs = np.linspace(x_range[0], x_range[1], 200)
    ys = m * xs + c
    return [{"x": round(float(xi), 4), "y": round(float(yi), 4)} for xi, yi in zip(xs, ys)]


def compute_intercepts(m: float, c: float) -> dict:
    """Return x-intercept and y-intercept for y = mx + c."""
    y_intercept = c
    x_intercept = (-c / m) if m != 0 else None
    return {
        "x_intercept": round(x_intercept, 4) if x_intercept is not None else None,
        "y_intercept": round(float(y_intercept), 4),
    }


def build_equation_string(m: float, c: float) -> str:
    """Build a human-readable equation string for y = mx + c (no sympy needed)."""
    m_str = str(int(m)) if m == int(m) else f"{m:.2f}".rstrip("0").rstrip(".")
    c_abs = abs(c)
    c_str = str(int(c_abs)) if c_abs == int(c_abs) else f"{c_abs:.2f}".rstrip("0").rstrip(".")

    if m == 1:
        m_part = "x"
    elif m == -1:
        m_part = "-x"
    else:
        m_part = f"{m_str}x"

    if c == 0:
        return f"y = {m_part}"
    sign = "+" if c > 0 else "-"
    return f"y = {m_part} {sign} {c_str}"
