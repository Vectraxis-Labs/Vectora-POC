from fastapi import APIRouter

router = APIRouter(prefix="/papers", tags=["papers"])

@router.get("/health")
def papers_health():
    return {"status": "papers module is alive"}