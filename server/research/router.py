from fastapi import APIRouter

router = APIRouter(prefix="/research", tags=["research"])

@router.get("/health")
def research_health():
    return {"status": "research module is alive"}