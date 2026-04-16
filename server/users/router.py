from fastapi import APIRouter

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/health")
def users_health():
    return {"status": "users module is alive"}