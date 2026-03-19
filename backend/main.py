"""
Math & Science Viz API — fully offline, no external network calls.
Uses only: numpy, Python stdlib.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import (
    linear, quadratic, geometry, chemistry, physics,
    calculus, trigonometry, statistics, progressions, vectors,
)

app = FastAPI(
    title="Math & Science Viz API",
    version="2.0.0",
    description="100% offline interactive math visualization backend. "
                "All computations done locally with numpy and Python stdlib.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://study-viz.web.app",
        "https://study-viz.firebaseapp.com",
        "http://localhost:3000",
        "http://localhost:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Core Math Modules ────────────────────────────────────────────
app.include_router(linear.router,       prefix="/api/linear",       tags=["Linear"])
app.include_router(quadratic.router,    prefix="/api/quadratic",    tags=["Quadratic"])
app.include_router(geometry.router,     prefix="/api/geometry",     tags=["Geometry"])
app.include_router(calculus.router,     prefix="/api/calculus",     tags=["Calculus"])
app.include_router(trigonometry.router, prefix="/api/trig",         tags=["Trigonometry"])
app.include_router(statistics.router,   prefix="/api/stats",        tags=["Statistics"])
app.include_router(progressions.router, prefix="/api/progressions", tags=["Progressions"])
app.include_router(vectors.router,      prefix="/api/vectors",      tags=["Vectors"])

# ── Chemistry & Physics Extensions ───────────────────────────────
app.include_router(chemistry.router, prefix="/api/chemistry", tags=["Chemistry"])
app.include_router(physics.router,   prefix="/api/physics",   tags=["Physics"])


@app.get("/", tags=["Health"])
def root():
    return {
        "message": "Math & Science Viz API v2.0 — fully offline",
        "docs": "/docs",
        "health": "/health",
    }


@app.get("/health", tags=["Health"])
def health():
    return {"status": "ok", "offline": True}
