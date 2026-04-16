from fastapi import APIRouter

# APIRouter is like a mini FastAPI app
# prefix means all routes in this file start with /auth
# tags groups them together in the Swagger docs
router = APIRouter(prefix="/auth", tags=["auth"])

@router.get("/health")
def auth_health():
    return {"status": "auth module is alive"}