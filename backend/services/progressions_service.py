"""
Progressions service — 100% offline using Python stdlib.
Generates AP and GP sequences and their sum / visualization data.
"""


def arithmetic_progression(first: float, diff: float, count: int) -> dict:
    """Generate an Arithmetic Progression."""
    terms = [round(first + i * diff, 6) for i in range(count)]
    n = count
    s_n = round(n / 2 * (2 * first + (n - 1) * diff), 6)
    nth_term = round(first + (n - 1) * diff, 6)
    return {
        "type": "AP",
        "first_term": first,
        "common_difference": diff,
        "count": count,
        "terms": terms,
        "nth_term": nth_term,
        "sum": s_n,
        "formula": f"aₙ = {first} + (n-1)×{diff}",
        "sum_formula": f"Sₙ = n/2 × [2×{first} + (n-1)×{diff}]",
        "points": [{"n": i + 1, "value": v} for i, v in enumerate(terms)],
    }


def geometric_progression(first: float, ratio: float, count: int) -> dict:
    """Generate a Geometric Progression."""
    terms = [round(first * (ratio ** i), 6) for i in range(count)]
    if abs(ratio) != 1:
        s_n = round(first * (ratio ** count - 1) / (ratio - 1), 6)
    else:
        s_n = round(first * count, 6)
    nth_term = round(first * (ratio ** (count - 1)), 6)
    return {
        "type": "GP",
        "first_term": first,
        "common_ratio": ratio,
        "count": count,
        "terms": terms,
        "nth_term": nth_term,
        "sum": s_n,
        "formula": f"aₙ = {first} × {ratio}^(n-1)",
        "sum_formula": f"Sₙ = {first}×({ratio}^n - 1) / ({ratio}-1)",
        "points": [{"n": i + 1, "value": v} for i, v in enumerate(terms)],
    }
