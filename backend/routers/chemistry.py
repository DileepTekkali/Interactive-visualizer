from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from services.chemistry_service import ChemistryService

router = APIRouter(prefix="/chemistry", tags=["Chemistry"])

# Schemas
class MoleculeRequest(BaseModel):
    atoms: List[str]

class ReactionRequest(BaseModel):
    reactants: List[str]

@router.get("/atom/{symbol}")
def get_atom(symbol: str):
    data = ChemistryService.get_atom_data(symbol)
    if not data.get("success"):
        raise HTTPException(status_code=404, detail=data["error"])
    return data

@router.post("/molecule/build")
def build_molecule(request: MoleculeRequest):
    if not request.atoms:
        raise HTTPException(status_code=400, detail="Must provide at least one atom.")
    
    result = ChemistryService.build_molecule(request.atoms)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result["error"])
    return result

@router.post("/reaction/run")
def run_reaction(request: ReactionRequest):
    if not request.reactants:
        raise HTTPException(status_code=400, detail="Must provide reactants.")
        
    result = ChemistryService.simulate_reaction(request.reactants)
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result["error"])
    return result

@router.get("/state/simulate")
def simulate_state(state: str, count: int = 50):
    """
    Simulates the atomic particle distribution and velocities based on state.
    state: 'solid', 'liquid', or 'gas'
    count: integer (default 50)
    """
    result = ChemistryService.simulate_state(state, count)
    if not result.get("success"): raise HTTPException(status_code=400, detail=result["error"])
    return result

@router.get("/separation")
def separation_process(method: str = "filtration"):
    return ChemistryService.separation_process(method)

@router.get("/change_detector")
def change_detector(scenario: str):
    return ChemistryService.change_detector(scenario)

@router.get("/atom_builder")
def atom_builder(p: int = 1, n: int = 0, e: int = 1):
    result = ChemistryService.atom_builder(p, n, e)
    if not result.get("success"): raise HTTPException(400, result.get("error"))
    return result

@router.get("/bond")
def chemical_bonding(el1: str, el2: str):
    return ChemistryService.chemical_bonding(el1, el2)

class MoleRequest(BaseModel):
    value: float
    mode: str
    molar_mass: float

@router.post("/mole_calculator")
def mole_calculator(req: MoleRequest):
    result = ChemistryService.mole_calculator(req.value, req.mode, req.molar_mass)
    if not result.get("success"): raise HTTPException(400, result.get("error"))
    return result

@router.get("/kinetics")
def kinetics_graph(concentration: float = 1.0, k: float = 0.1, order: int = 1):
    return ChemistryService.reaction_kinetics(concentration, k, order)

@router.get("/equilibrium")
def equilibrium_simulator(temp_change: float = 0.0):
    return ChemistryService.equilibrium_simulator(temp_change)

@router.get("/thermodynamics")
def thermodynamics_viz(rxn_type: str = "exothermic"):
    return ChemistryService.thermodynamics_viz(rxn_type)
