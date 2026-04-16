from fastapi import APIRouter

router = APIRouter(prefix="/peers", tags=["peers"])

@router.get("/health")
def peers_health():
    return {"status": "peers module is alive"}