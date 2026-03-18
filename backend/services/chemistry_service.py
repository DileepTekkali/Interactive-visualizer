import numpy as np
import random
from typing import List, Dict, Any, Tuple

# Core Periodic Table Data
PERIODIC_TABLE = {
    "H": {"atomic_number": 1, "name": "Hydrogen", "valency": 1, "shells": [1]},
    "He": {"atomic_number": 2, "name": "Helium", "valency": 0, "shells": [2]},
    "C": {"atomic_number": 6, "name": "Carbon", "valency": 4, "shells": [2, 4]},
    "N": {"atomic_number": 7, "name": "Nitrogen", "valency": 3, "shells": [2, 5]},
    "O": {"atomic_number": 8, "name": "Oxygen", "valency": 2, "shells": [2, 6]},
    "Na": {"atomic_number": 11, "name": "Sodium", "valency": 1, "shells": [2, 8, 1]},
    "Cl": {"atomic_number": 17, "name": "Chlorine", "valency": 1, "shells": [2, 8, 7]},
}

class ChemistryService:
    
    @staticmethod
    def get_atom_data(symbol: str) -> Dict[str, Any]:
        """Retrieve atomic structure data."""
        data = PERIODIC_TABLE.get(symbol.capitalize())
        if not data:
            return {"error": f"Element {symbol} not found in database.", "success": False}
        return {"symbol": symbol.capitalize(), **data, "success": True}

    @staticmethod
    def build_molecule(atoms: List[str]) -> Dict[str, Any]:
        """
        Builds a basic 3D representation of a molecule given a list of atoms.
        We will formulate a simple approach for common molecules (H2O, O2, CO2, CH4, NaCl).
        For an educational simulator, generating exact geometries dynamically is complex,
        so we use known geometric templates if recognized, otherwise we generate a generic chain.
        """
        # Count atoms to create formula string roughly
        counts = {}
        for a in atoms:
            counts[a] = counts.get(a, 0) + 1
        
        formula = "".join([f"{k}{v if v > 1 else ''}" for k, v in sorted(counts.items())])
        
        # Hardcoded templates for common educational molecules
        # These provide nice 3D coordinates for Flutter to render
        templates = {
            "H2O": {
                "atoms": [
                    {"id": "O1", "symbol": "O", "position": [0.0, 0.0, 0.0]},
                    {"id": "H1", "symbol": "H", "position": [0.8, -0.6, 0.0]},
                    {"id": "H2", "symbol": "H", "position": [-0.8, -0.6, 0.0]}
                ],
                "bonds": [
                    {"from": "O1", "to": "H1", "type": 1},
                    {"from": "O1", "to": "H2", "type": 1}
                ]
            },
            "CO2": {
                "atoms": [
                    {"id": "C1", "symbol": "C", "position": [0.0, 0.0, 0.0]},
                    {"id": "O1", "symbol": "O", "position": [1.2, 0.0, 0.0]},
                    {"id": "O2", "symbol": "O", "position": [-1.2, 0.0, 0.0]}
                ],
                "bonds": [
                    {"from": "C1", "to": "O1", "type": 2},
                    {"from": "C1", "to": "O2", "type": 2}
                ]
            },
            "CH4": { # Tetrahedral methane
                "atoms": [
                    {"id": "C1", "symbol": "C", "position": [0.0, 0.0, 0.0]},
                    {"id": "H1", "symbol": "H", "position": [0.0, 1.0, 0.0]},
                    {"id": "H2", "symbol": "H", "position": [0.94, -0.33, 0.0]},
                    {"id": "H3", "symbol": "H", "position": [-0.47, -0.33, 0.81]},
                    {"id": "H4", "symbol": "H", "position": [-0.47, -0.33, -0.81]}
                ],
                "bonds": [
                    {"from": "C1", "to": "H1", "type": 1},
                    {"from": "C1", "to": "H2", "type": 1},
                    {"from": "C1", "to": "H3", "type": 1},
                    {"from": "C1", "to": "H4", "type": 1}
                ]
            },
            "O2": {
                "atoms": [
                    {"id": "O1", "symbol": "O", "position": [-0.6, 0.0, 0.0]},
                    {"id": "O2", "symbol": "O", "position": [0.6, 0.0, 0.0]}
                ],
                "bonds": [
                    {"from": "O1", "to": "O2", "type": 2} # Double bond
                ]
            },
            "H2": {
                "atoms": [
                    {"id": "H1", "symbol": "H", "position": [-0.4, 0.0, 0.0]},
                    {"id": "H2", "symbol": "H", "position": [0.4, 0.0, 0.0]}
                ],
                "bonds": [
                    {"from": "H1", "to": "H2", "type": 1}
                ]
            },
            "ClNa": { # NaCl usually written ClNa if sorted alphabetically, let's fix
                 "atoms": [
                    {"id": "Na1", "symbol": "Na", "position": [-0.8, 0.0, 0.0]},
                    {"id": "Cl1", "symbol": "Cl", "position": [0.8, 0.0, 0.0]}
                ],
                "bonds": [
                    {"from": "Na1", "to": "Cl1", "type": 1} # Ionic represented as single line for viz
                ]
            }
        }
        
        # Check sorted formula or inverted
        formula_sorted = "".join(sorted(formula))
        
        # Determine strict matching for demo purposes
        hit = templates.get(formula)
        if not hit and formula == "ClNa":
            hit = templates.get("ClNa")
            formula = "NaCl" # standard notation

        if hit:
            return {"success": True, "molecule": formula, **hit}

        # Fallback generic chain builder (Linear)
        generated_atoms = []
        generated_bonds = []
        for i, symbol in enumerate(atoms):
            if symbol not in PERIODIC_TABLE:
                return {"success": False, "error": f"Unknown atom {symbol}"}
            
            atom_id = f"{symbol}{i+1}"
            # place along X axis
            generated_atoms.append({
                "id": atom_id,
                "symbol": symbol,
                "position": [i * 1.0, 0.0, 0.0]  
            })
            
            if i > 0:
                prev_id = f"{atoms[i-1]}{i}"
                generated_bonds.append({
                    "from": prev_id,
                    "to": atom_id,
                    "type": 1
                })

        return {
            "success": True, 
            "molecule": "Custom Generic", 
            "atoms": generated_atoms, 
            "bonds": generated_bonds
        }

    @staticmethod
    def simulate_reaction(reactants: List[str]) -> Dict[str, Any]:
        """
        Simulates step-by-step chemical reaction logic suitable for a frontend animation timeline.
        """
        # A simple reaction dictionary mapping standard reactants to products
        # Used for educational visualization steps
        key = " + ".join(sorted(reactants))
        
        reactions = {
            "H2 + H2 + O2": {
                "name": "Combustion of Hydrogen",
                "equation": "2H2 + O2 → 2H2O",
                "steps": [
                    {"step": 1, "action": "INITIAL", "description": "Reactants in container: 2 H2 molecules and 1 O2 molecule."},
                    {"step": 2, "action": "BREAK_BONDS", "description": "Energy added: H-H bonds and O=O double bonds break."},
                    {"step": 3, "action": "REARRANGE", "description": "Free oxygen atoms attract hydrogen atoms."},
                    {"step": 4, "action": "FORM_BONDS", "description": "New O-H covalent bonds form."},
                    {"step": 5, "action": "FINAL", "description": "Products formed: 2 H2O molecules."}
                ],
                "products": ["H2O", "H2O"]
            },
            "C + O2": {
                "name": "Combustion of Carbon",
                "equation": "C + O2 → CO2",
                "steps": [
                    {"step": 1, "action": "INITIAL", "description": "Reactants: 1 Carbon atom and 1 O2 molecule."},
                    {"step": 2, "action": "BREAK_BONDS", "description": "O=O double bond breaks."},
                    {"step": 3, "action": "FORM_BONDS", "description": "Carbon forms double bonds with two Oxygen atoms."},
                    {"step": 4, "action": "FINAL", "description": "Product formed: CO2."}
                ],
                "products": ["CO2"]
            }
        }

        rxn = reactions.get(key)
        if not rxn:
            return {"success": False, "error": f"No reaction found for {key}. Try 'H2', 'H2', 'O2'."}
        
        return {"success": True, **rxn}

    @staticmethod
    def simulate_state(state: str, count: int = 50) -> Dict[str, Any]:
        """
        Generates initial particle positions and velocity vectors based on state of matter.
        """
        particles = []
        state_config = {
            "solid": {"jitter": 0.1, "spacing": 0.8, "speed": 0.05, "arrangement": "lattice"},
            "liquid": {"jitter": 0.4, "spacing": 1.0, "speed": 0.3, "arrangement": "random_dense"},
            "gas": {"jitter": 2.0, "spacing": 3.0, "speed": 1.2, "arrangement": "random_sparse"}
        }

        conf = state_config.get(state.lower())
        if not conf:
            return {"success": False, "error": "Invalid state. Choose solid, liquid, or gas."}

        # Box dimensions for simulation
        box_size = 10.0

        if conf["arrangement"] == "lattice":
            # Grid placement for solid
            grid_dim = int(np.ceil(count ** (1/3)))
            idx = 0
            for x in range(grid_dim):
                for y in range(grid_dim):
                    for z in range(grid_dim):
                        if idx >= count: break
                        
                        # Apply small vibrating velocity
                        vx = random.uniform(-conf["speed"], conf["speed"])
                        vy = random.uniform(-conf["speed"], conf["speed"])
                        vz = random.uniform(-conf["speed"], conf["speed"])

                        # Lattice pos centered
                        px = (x - grid_dim/2) * conf["spacing"]
                        py = (y - grid_dim/2) * conf["spacing"]
                        pz = (z - grid_dim/2) * conf["spacing"]

                        particles.append({
                            "id": idx,
                            "pos": [px, py, pz],
                            "vel": [vx, vy, vz]
                        })
                        idx += 1
        else:
            # Random placement for liquid/gas
            for idx in range(count):
                bound = box_size / 2
                if state.lower() == "liquid":
                    # Liquid pools at the bottom usually, but let's just make it a dense random clump
                    bound = box_size / 4

                px = random.uniform(-bound, bound)
                py = random.uniform(-bound, bound)
                pz = random.uniform(-bound, bound)

                vx = random.uniform(-conf["speed"], conf["speed"])
                vy = random.uniform(-conf["speed"], conf["speed"])
                vz = random.uniform(-conf["speed"], conf["speed"])

                particles.append({
                    "id": idx,
                    "pos": [px, py, pz],
                    "vel": [vx, vy, vz]
                })

        return {
            "success": True,
            "state": state.lower(),
            "count": count,
            "box_size": box_size,
            "particles": particles
        }

    @staticmethod
    def separation_process(method: str) -> Dict[str, Any]:
        """Provides steps and visuals for separation techniques."""
        if method.lower() == "filtration":
            return {"success": True, "method": method, "steps": [
                {"id": 1, "desc": "Mix salt and sand in water."},
                {"id": 2, "desc": "Pour mixture through filter paper into beaker."},
                {"id": 3, "desc": "Wash residue with distilled water."},
            ]}
        elif method.lower() == "evaporation":
            return {"success": True, "method": method, "steps": [
                {"id": 1, "desc": "Pour salt water solution into evaporating dish."},
                {"id": 2, "desc": "Heat solution until water evaporates."},
                {"id": 3, "desc": "Crystals of salt remain in the dish."},
            ]}
        return {"success": False, "error": f"Unknown separation method: {method}"}

    @staticmethod
    def change_detector(scenario: str) -> Dict[str, Any]:
        """Classifies scenario as physical or chemical change."""
        scenario_lower = scenario.lower()
        
        # Keywords indicating chemical identity change
        chemical_keywords = [
            "burn", "rust", "react", "bake", "cook", "acid", "gas", "precipitate", 
            "oxidize", "tarnish", "ferment", "rot", "digestion", "photosynthesis",
            "explosion", "combustion", "bubbles", "color change", "odor"
        ]
        
        # Keywords traditionally associated with physical changes
        physical_keywords = [
            "melt", "freeze", "boil", "condense", "sublimation", "evaporate",
            "shred", "chop", "mix", "break", "cut", "crush", "dissolve", "bend"
        ]
        
        is_chemical = any(k in scenario_lower for k in chemical_keywords)
        is_physical = any(k in scenario_lower for k in physical_keywords)
        
        # Heuristic override: if "melting" is mentioned, it's usually physical even if other words present
        if "melt" in scenario_lower or "freeze" in scenario_lower or "boil" in scenario_lower:
            is_chemical = False
        
        change_type = "Chemical" if is_chemical else "Physical"
        explanation = (
            "New substances are formed as chemical bonds are broken and created." 
            if is_chemical else 
            "The substance changes state or form, but its chemical identity remains identical."
        )
        
        return {
            "success": True,
            "scenario": scenario,
            "type": change_type,
            "explanation": explanation
        }

    @staticmethod
    def atom_builder(p: int, n: int, e: int) -> Dict[str, Any]:
        """Calculates element, charge, and mass."""
        if p == 0: return {"success": False, "error": "Protons cannot be 0"}
        mass = p + n
        charge = p - e
        
        # Determine symbol
        symbol = "Unknown"
        name = "Unknown Element"
        for s, data in PERIODIC_TABLE.items():
            if data["atomic_number"] == p:
                symbol = s
                name = data["name"]
                break
                
        return {
            "success": True,
            "element": name,
            "symbol": symbol,
            "mass": mass,
            "charge": charge,
            "is_stable": p == n  # highly simplified logic
        }

    @staticmethod
    def chemical_bonding(el1: str, el2: str) -> Dict[str, Any]:
        """Determines bond type based on typical element properties."""
        # Highly simplified heuristic for demo
        metals = ["Na", "Li", "K", "Mg", "Ca"]
        m1 = el1.capitalize() in metals
        m2 = el2.capitalize() in metals
        
        if m1 and m2: bond = "Metallic"
        elif m1 != m2: bond = "Ionic"
        else: bond = "Covalent"
        
        return {"success": True, "elements": [el1, el2], "bond_type": bond}

    @staticmethod
    def mole_calculator(value: float, mode: str, molar_mass: float) -> Dict[str, Any]:
        """Converts between mass, moles, and particles."""
        if value < 0 or molar_mass <= 0: return {"success": False, "error": "Invalid values"}
        avogadro = 6.022e23
        
        if mode == "mass_to_moles":
            return {"success": True, "result": value / molar_mass, "unit": "mol"}
        elif mode == "moles_to_mass":
            return {"success": True, "result": value * molar_mass, "unit": "g"}
        elif mode == "moles_to_particles":
            return {"success": True, "result": value * avogadro, "unit": "particles"}
        return {"success": False, "error": "Unknown mode"}

    @staticmethod
    def reaction_kinetics(concentration: float, rate_constant: float, order: int) -> Dict[str, Any]:
        """Generates time series graph of concentration decays."""
        t = np.linspace(0, 50, 20)
        
        if order == 0:
            c = concentration - rate_constant * t
            c = np.maximum(c, 0)
        elif order == 1:
            c = concentration * np.exp(-rate_constant * t)
        else:
            c = 1 / ((1/concentration) + rate_constant * t)
            
        return {
            "success": True,
            "order": order,
            "time": t.round(2).tolist(),
            "concentration": c.round(3).tolist()
        }

    @staticmethod
    def equilibrium_simulator(temp_change: float) -> Dict[str, Any]:
        """Le Chatelier simulator (simplified exothermic baseline)."""
        shift = "Right (Products)" if temp_change < 0 else "Left (Reactants)"
        return {
            "success": True,
            "stimulus": f"Temp change {'+' if temp_change > 0 else ''}{temp_change}°C",
            "shift": shift
        }

    @staticmethod
    def thermodynamics_viz(rxn_type: str) -> Dict[str, Any]:
        """Generates energy profile curves."""
        x = np.linspace(0, 10, 50)
        # generic gaussian activation curve
        activation = 50 * np.exp(-(x - 4)**2 / 2)
        
        if rxn_type.lower() == "exothermic":
            y = 80 - 10 * x + activation
        else:
            y = 20 + 10 * x + activation
            
        return {
            "success": True,
            "type": rxn_type,
            "progress": x.round(2).tolist(),
            "energy": y.round(2).tolist()
        }
