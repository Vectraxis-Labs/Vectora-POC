from fastapi import APIRouter

router = APIRouter(prefix="/ai", tags=["ai"])

@router.get("/health")
def ai_health():
    return {"status": "ai module is alive"}