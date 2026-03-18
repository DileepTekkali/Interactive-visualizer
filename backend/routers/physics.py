from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from services.physics_service import PhysicsService

router = APIRouter(prefix="/physics", tags=["Physics"])

class CircuitRequest(BaseModel):
    resistors: List[float]
    voltage: float
    is_series: bool = True

@router.get("/friction")
def friction_simulator(mass: float = 10.0, mu: float = 0.5, angle: float = 0.0):
    result = PhysicsService.calculate_friction(mass, mu, angle)
    if not result.get("success"): raise HTTPException(400, "Calculation failed")
    return result

@router.get("/heat_transfer")
def heat_transfer(mode: str = "conduction", delta_t: float = 50.0):
    result = PhysicsService.get_heat_transfer_data(mode, delta_t)
    if not result.get("success"): raise HTTPException(400, "Calculation failed")
    return result

@router.get("/lever")
def lever_machine(effort_arm: float = 2.0, load_arm: float = 1.0, load_mass: float = 10.0):
    result = PhysicsService.calculate_lever(effort_arm, load_arm, load_mass)
    if not result.get("success"): raise HTTPException(400, "Calculation failed")
    return result

@router.get("/motion")
def motion_graph(accel: float = 1.0, initial_v: float = 0.0, time: float = 10.0):
    result = PhysicsService.generate_motion_graph(accel, initial_v, time)
    if not result.get("success"): raise HTTPException(400, "Calculation failed")
    return result

@router.get("/newtons_laws")
def newtons_laws(force: float = 10.0, mass: float = 2.0):
    result = PhysicsService.test_newtons_laws(force, mass)
    if not result.get("success"): raise HTTPException(400, "Calculation failed")
    return result

@router.get("/energy")
def energy_simulator(mass: float = 1.0, height: float = 10.0, velocity: float = 0.0):
    result = PhysicsService.simulate_energy(mass, height, velocity)
    if not result.get("success"): raise HTTPException(400, "Calculation failed")
    return result

@router.get("/optics")
def light_ray_simulator(angle: float = 45.0, n1: float = 1.0, n2: float = 1.5):
    result = PhysicsService.optics_ray(angle, n1, n2)
    if not result.get("success"): raise HTTPException(400, "Calculation failed")
    return result

@router.post("/circuit")
def circuit_simulator(request: CircuitRequest):
    result = PhysicsService.evaluate_circuit(request.voltage, request.resistors, request.is_series)
    if not result.get("success"): raise HTTPException(400, "Calculation failed")
    return result

@router.get("/magnetic_field")
def magnetic_field(magnet_strength: float = 1.0):
    result = PhysicsService.magnetic_field(magnet_strength)
    if not result.get("success"): raise HTTPException(400, "Calculation failed")
    return result

@router.get("/wave")
def wave_simulator(amplitude: float = 1.0, frequency: float = 1.0, phase: float = 0.0):
    result = PhysicsService.simulate_wave(amplitude, frequency, phase)
    if not result.get("success"): raise HTTPException(400, "Calculation failed")
    return result
