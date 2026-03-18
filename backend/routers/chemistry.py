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
    if not result.get("success"):
        raise HTTPException(status_code=400, detail=result["error"])
    return result
