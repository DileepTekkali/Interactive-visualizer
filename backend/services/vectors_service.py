"""
Vectors service — 100% offline using numpy.
2D and 3D vector computations: addition, dot product, cross product, magnitude, angle.
"""
import numpy as np
import math


def vector_operations(v1: list, v2: list) -> dict:
    """
    Full vector analysis for 2D or 3D vectors.
    v1, v2: lists of 2 or 3 floats.
    """
    a = np.array(v1, dtype=float)
    b = np.array(v2, dtype=float)

    if len(a) != len(b) or len(a) not in (2, 3):
        return {"error": "Vectors must be 2D or 3D and same dimension."}

    addition = (a + b).tolist()
    subtraction = (a - b).tolist()
    mag_a = float(np.linalg.norm(a))
    mag_b = float(np.linalg.norm(b))
    dot = float(np.dot(a, b))

    angle_rad = math.acos(max(-1, min(1, dot / (mag_a * mag_b)))) if mag_a > 0 and mag_b > 0 else 0
    angle_deg = math.degrees(angle_rad)

    result = {
        "v1": v1,
        "v2": v2,
        "addition": [round(x, 4) for x in addition],
        "subtraction": [round(x, 4) for x in subtraction],
        "magnitude_v1": round(mag_a, 4),
        "magnitude_v2": round(mag_b, 4),
        "dot_product": round(dot, 4),
        "angle_degrees": round(angle_deg, 4),
        "angle_radians": round(angle_rad, 6),
        "unit_v1": [round(x, 5) for x in (a / mag_a).tolist()] if mag_a > 0 else v1,
        "unit_v2": [round(x, 5) for x in (b / mag_b).tolist()] if mag_b > 0 else v2,
    }

    # Cross product only for 3D
    if len(a) == 3:
        cross = np.cross(a, b).tolist()
        result["cross_product"] = [round(x, 4) for x in cross]

    return result
