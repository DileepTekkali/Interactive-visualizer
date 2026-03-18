import numpy as np
import math
from typing import Dict, Any, List

class PhysicsService:
    @staticmethod
    def calculate_friction(mass: float, mu: float, angle: float = 0.0) -> Dict[str, Any]:
        """Calculates forces on an inclined or flat plane with friction."""
        g = 9.81
        theta = math.radians(angle)
        normal_force = mass * g * math.cos(theta)
        max_static_friction = mu * normal_force
        parallel_force = mass * g * math.sin(theta)
        
        return {
            "success": True,
            "normal_force": round(normal_force, 2),
            "max_friction": round(max_static_friction, 2),
            "force_down_plane": round(parallel_force, 2),
            "will_slide": parallel_force > max_static_friction
        }

    @staticmethod
    def get_heat_transfer_data(mode: str, delta_t: float = 50.0) -> Dict[str, Any]:
        """Provides theoretical heat flow curves across a material or air depending on mode."""
        time_steps = np.linspace(0, 10, 20)
        
        if mode.lower() == "conduction":
            heat_curve = delta_t * (1 - np.exp(-0.2 * time_steps))
        elif mode.lower() == "convection":
            heat_curve = delta_t * (1 - np.exp(-0.5 * time_steps))
        else: # radiation
            heat_curve = delta_t * (1 - np.exp(-1.0 * time_steps))
            
        return {
            "success": True, 
            "mode": mode,
            "time_steps": time_steps.round(2).tolist(),
            "heat_curve": heat_curve.round(2).tolist()
        }

    @staticmethod
    def calculate_lever(effort_arm: float, load_arm: float, load_mass: float) -> Dict[str, Any]:
        """Calculates simple machine lever forces."""
        g = 9.81
        load_force = load_mass * g
        mechanical_advantage = effort_arm / load_arm if load_arm > 0 else 0
        required_effort = load_force / mechanical_advantage if mechanical_advantage > 0 else 0
        
        return {
            "success": True,
            "mechanical_advantage": round(mechanical_advantage, 2),
            "load_force": round(load_force, 2),
            "effort_required": round(required_effort, 2)
        }

    @staticmethod
    def generate_motion_graph(accel: float, initial_v: float = 0.0, time: float = 10.0) -> Dict[str, Any]:
        """Generates kinematic data arrays: p(t), v(t), a(t)."""
        t = np.linspace(0, time, 50)
        v = initial_v + accel * t
        d = (initial_v * t) + (0.5 * accel * t**2)
        
        return {
            "success": True,
            "time": t.round(2).tolist(),
            "velocity": v.round(2).tolist(),
            "position": d.round(2).tolist()
        }

    @staticmethod
    def test_newtons_laws(force: float, mass: float) -> Dict[str, Any]:
        """Demonstrates F=ma."""
        acceleration = force / mass if mass > 0 else 0
        return {
            "success": True,
            "acceleration": round(acceleration, 2),
            "force": force,
            "mass": mass,
            "law_statement": f"An object with mass {mass}kg accelerated by {force}N force results in {round(acceleration, 2)}m/s² acceleration (F=ma)."
        }

    @staticmethod
    def simulate_energy(mass: float, height: float, velocity: float = 0.0) -> Dict[str, Any]:
        """Calculates kinetic, potential, and total energy."""
        g = 9.81
        pe = mass * g * height
        ke = 0.5 * mass * velocity**2
        return {
            "success": True,
            "potential_energy": round(pe, 2),
            "kinetic_energy": round(ke, 2),
            "total_energy": round(pe + ke, 2)
        }

    @staticmethod
    def optics_ray(angle_incidence: float, n1: float = 1.0, n2: float = 1.5) -> Dict[str, Any]:
        """Calculates reflection and refraction angles using Snell's Law."""
        rad_incident = math.radians(angle_incidence)
        
        sin_refracted = (n1 / n2) * math.sin(rad_incident)
        # Check for total internal reflection
        if sin_refracted > 1.0 or sin_refracted < -1.0:
            return {
                "success": True,
                "angle_reflection": angle_incidence,
                "total_internal_reflection": True,
                "angle_refraction": None
            }
            
        angle_refraction = math.degrees(math.asin(sin_refracted))
        return {
            "success": True,
            "incident_angle_deg": angle_incidence,
            "angle_reflection": angle_incidence,
            "total_internal_reflection": False,
            "refracted_angle_deg": round(angle_refraction, 2)
        }

    @staticmethod
    def evaluate_circuit(voltage: float, resistors: List[float], series: bool = True) -> Dict[str, Any]:
        """Evaluates simple R circuits."""
        if series:
            req = sum(resistors)
            current = voltage / req if req > 0 else 0
            # V = I*R for each
            dist = [round(current * r, 2) for r in resistors]
            return {"success": True, "type": "series", "equivalent_resistance": round(req, 2), "total_current": round(current, 2), "voltage_drops": dist}
        else:
            # Parallel
            inv_req = sum([1/r for r in resistors if r > 0])
            req = 1 / inv_req if inv_req > 0 else 0
            total_current = voltage / req if req > 0 else 0
            # I = V/R for each branch
            dist = [round(voltage / r, 2) for r in resistors if r > 0]
            return {"success": True, "type": "parallel", "equivalent_resistance": round(req, 2), "total_current": round(total_current, 2), "current_branches": dist}

    @staticmethod
    def magnetic_field(magnet_strength: float = 1.0) -> Dict[str, Any]:
        """Generates a simple 2D grid vector field based on a dipole model."""
        # Simple grid
        x = np.linspace(-5, 5, 10)
        y = np.linspace(-5, 5, 10)
        X, Y = np.meshgrid(x, y)
        
        # Approximate 2D dipole field B ~ (3(m.r)r - m(r^2)) / r^5
        # m = [magnet_strength, 0]
        # For simplicity in 2D viz:
        r2 = X**2 + Y**2 + 0.1 # avoid division by zero
        r3 = r2**1.5
        r5 = r2**2.5
        
        Bx = magnet_strength * (3 * X**2 - r2) / r5
        By = magnet_strength * (3 * X * Y) / r5
        
        # Flatten for JSON
        x_flat = X.flatten().round(2).tolist()
        y_flat = Y.flatten().round(2).tolist()
        Bx_flat = Bx.flatten().round(3).tolist()
        By_flat = By.flatten().round(3).tolist()
        
        return {
            "success": True,
            "x": x_flat,
            "y": y_flat,
            "u": Bx_flat,
            "v": By_flat
        }

    @staticmethod
    def simulate_wave(amplitude: float, frequency: float, phase: float = 0.0) -> Dict[str, Any]:
        """Generates sinusoidal waveform points."""
        x = np.linspace(0, 4 * math.pi, 100)
        y = amplitude * np.sin(frequency * x + phase)
        return {
            "success": True,
            "x": x.round(2).tolist(),
            "y": y.round(2).tolist()
        }
