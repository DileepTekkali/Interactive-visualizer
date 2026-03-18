"""
Statistics service — 100% offline using numpy.
Generates descriptive stats, frequency tables, and histogram data.
"""
import numpy as np


def compute_stats(values: list) -> dict:
    """Compute descriptive statistics for a list of numbers."""
    arr = np.array(values, dtype=float)
    if len(arr) == 0:
        return {"error": "Empty dataset"}

    sorted_arr = np.sort(arr)
    n = len(arr)

    # Mean, Median, Mode (most frequent)
    mean = float(np.mean(arr))
    median = float(np.median(arr))
    unique, counts = np.unique(arr, return_counts=True)
    mode_val = float(unique[np.argmax(counts)])

    # Variance and std
    variance = float(np.var(arr))
    std_dev = float(np.std(arr))
    q1 = float(np.percentile(arr, 25))
    q3 = float(np.percentile(arr, 75))

    return {
        "count": n,
        "mean": round(mean, 4),
        "median": round(median, 4),
        "mode": round(mode_val, 4),
        "variance": round(variance, 4),
        "std_dev": round(std_dev, 4),
        "min": round(float(arr.min()), 4),
        "max": round(float(arr.max()), 4),
        "range": round(float(arr.max() - arr.min()), 4),
        "q1": round(q1, 4),
        "q3": round(q3, 4),
        "iqr": round(q3 - q1, 4),
        "sorted": sorted_arr.tolist(),
    }


def compute_histogram(values: list, bins: int = 10) -> dict:
    """
    Compute histogram bin data for a bar chart.
    Returns bin edges and counts ready for Flutter rendering.
    """
    arr = np.array(values, dtype=float)
    counts, edges = np.histogram(arr, bins=bins)
    bars = []
    for i in range(len(counts)):
        bars.append({
            "from": round(float(edges[i]), 3),
            "to": round(float(edges[i + 1]), 3),
            "label": f"{edges[i]:.1f}–{edges[i+1]:.1f}",
            "count": int(counts[i]),
        })
    return {"bins": bars, "total": int(arr.size)}


def generate_normal_sample(mean: float, std: float, count: int) -> list:
    """Generate a normal-distribution sample for demonstration."""
    rng = np.random.default_rng(seed=42)
    return [round(float(v), 3) for v in rng.normal(mean, std, count)]
