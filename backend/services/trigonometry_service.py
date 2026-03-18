"""
Trigonometry service — 100% offline using numpy.
Generates sin/cos/tan waveform data for visualization.
"""
import numpy as np
import math


def compute_wave(func: str, amplitude: float, frequency: float,
                 phase: float, x_min: float, x_max: float) -> dict:
    """
    Generate waveform points for sin/cos/tan.
    Returns points list + key annotations (peaks, zero crossings).
    """
    xs = np.linspace(x_min, x_max, 400)

    if func == "cos":
        ys = amplitude * np.cos(frequency * xs + phase)
        label = f"f(x) = {amplitude:.1f}·cos({frequency:.1f}x + {phase:.1f})"
    elif func == "tan":
        raw = np.tan(frequency * xs + phase)
        # Clip extremes for clean rendering
        ys = np.clip(raw, -10, 10)
        label = f"f(x) = tan({frequency:.1f}x)"
    else:  # default sin
        ys = amplitude * np.sin(frequency * xs + phase)
        label = f"f(x) = {amplitude:.1f}·sin({frequency:.1f}x + {phase:.1f})"

    # Period
    period = round(2 * math.pi / frequency, 4) if frequency != 0 else None

    return {
        "func": func,
        "label": label,
        "amplitude": amplitude,
        "period": period,
        "points": [{"x": round(float(x), 4), "y": round(float(y), 4)} for x, y in zip(xs, ys)],
        "key_values": {
            "max": round(float(np.max(ys)), 4),
            "min": round(float(np.min(ys)), 4),
        }
    }


def compute_unit_circle_point(angle_deg: float) -> dict:
    """Return x, y, sin, cos, tan for an angle in degrees."""
    rad = math.radians(angle_deg)
    return {
        "angle_deg": angle_deg,
        "angle_rad": round(rad, 5),
        "x": round(math.cos(rad), 5),
        "y": round(math.sin(rad), 5),
        "sin": round(math.sin(rad), 5),
        "cos": round(math.cos(rad), 5),
        "tan": round(math.tan(rad), 5) if abs(math.cos(rad)) > 1e-9 else None,
    }
