from fastapi import APIRouter

router = APIRouter(prefix="/collections", tags=["collections"])

@router.get("/health")
def collections_health():
    return {"status": "collections module is alive"}