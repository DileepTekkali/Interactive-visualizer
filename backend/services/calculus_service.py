"""
Calculus service — 100% offline using numpy.
Provides derivative/integral computations returning structured JSON.
"""
import numpy as np


def compute_function(func_type: str, x_min: float, x_max: float, param: float = 1.0) -> dict:
    """
    Compute points, derivative points, and integral (area) for a given function type.
    Supported: 'polynomial', 'sine', 'exponential'
    """
    xs = np.linspace(x_min, x_max, 300)

    if func_type == "sine":
        ys = np.sin(param * xs)
        dys = param * np.cos(param * xs)      # d/dx sin(kx) = k*cos(kx)
        label = f"f(x) = sin({int(param)}x)" if param != 1 else "f(x) = sin(x)"
    elif func_type == "exponential":
        ys = np.exp(param * xs)
        dys = param * np.exp(param * xs)
        label = f"f(x) = e^({int(param)}x)" if param != 1 else "f(x) = e^x"
    else:  # polynomial default: f(x) = x^2 * param
        ys = param * xs**2
        dys = 2 * param * xs
        label = f"f(x) = {int(param)}x²" if param != 1 else "f(x) = x²"

    # Cumulative integral via trapezoidal rule
    integral_vals = np.zeros_like(ys)
    for i in range(1, len(xs)):
        integral_vals[i] = np.trapz(ys[:i+1], xs[:i+1])

    # Key stats
    area_total = float(np.trapz(ys, xs))
    max_y = float(np.max(ys))
    min_y = float(np.min(ys))

    return {
        "label": label,
        "func_type": func_type,
        "points": [{"x": round(float(x), 4), "y": round(float(y), 4)} for x, y in zip(xs, ys)],
        "derivative_points": [{"x": round(float(x), 4), "y": round(float(dy), 4)} for x, dy in zip(xs, dys)],
        "integral_points": [{"x": round(float(x), 4), "y": round(float(iv), 4)} for x, iv in zip(xs, integral_vals)],
        "stats": {
            "area_under_curve": round(area_total, 4),
            "max_value": round(max_y, 4),
            "min_value": round(min_y, 4),
        }
    }
