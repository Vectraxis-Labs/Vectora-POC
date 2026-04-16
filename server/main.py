from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# Import all the routers from each module
from auth.router import router as auth_router
from users.router import router as users_router
from papers.router import router as papers_router
from research.router import router as research_router
from user_collections.router import router as collections_router
from peers.router import router as peers_router
from ai.router import router as ai_router

# Load .env variables
load_dotenv()

# Create the FastAPI app
app = FastAPI(
    title="Vectora API",
    description="Backend API for the Vectora research platform",
    version="0.1.0",
)

# CORS — Cross-Origin Resource Sharing
# Without this, the browser blocks requests from the frontend (localhost:3000)
# to the backend (localhost:8000) because they're on different "origins" (ports)
# This middleware says "yes, requests from these origins are allowed"
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",    # Next.js dev server
    ],
    allow_credentials=True,
    allow_methods=["*"],           # allow GET, POST, PUT, DELETE, etc.
    allow_headers=["*"],           # allow all headers
)

# Register all routers with the app
# include_router is how FastAPI learns about each module's endpoints
app.include_router(auth_router)
app.include_router(users_router)
app.include_router(papers_router)
app.include_router(research_router)
app.include_router(collections_router)
app.include_router(peers_router)
app.include_router(ai_router)

# Root endpoint — just to confirm the server is alive
@app.get("/")
def root():
    return {"message": "Vectora API is running"}

# Health check endpoint — useful for infrastructure monitoring later
@app.get("/health")
def health():
    return {"status": "healthy", "version": "0.1.0"}