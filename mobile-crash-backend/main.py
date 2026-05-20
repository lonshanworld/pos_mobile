from fastapi import FastAPI, HTTPException, Depends, Request, Form, status
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import uvicorn

from config import settings
from database import db
from auth import verify_mobile_token, verify_admin_token, authenticate_admin, security

# Initialize FastAPI app
app = FastAPI(title="Mobile Crash Report Backend", version="1.0.0")

# Rate limiter
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Templates
templates = Jinja2Templates(directory="templates")

# Models
class CrashReport(BaseModel):
    errorMessage: str
    stackTrace: str
    deviceInfo: Optional[str] = None
    userInfo: Optional[str] = None
    appVersion: str
    platform: str
    timestamp: str
    errorType: str

class CrashReportBatch(BaseModel):
    reports: List[CrashReport]

class LoginRequest(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

# Startup event
@app.on_event("startup")
async def startup_event():
    """Initialize database on startup"""
    await db.init_db()

# API Routes
@app.post("/api/crash-reports", response_model=dict)
@limiter.limit(f"{settings.RATE_LIMIT_PER_MINUTE}/minute")
async def receive_crash_reports(
    request: Request,
    batch: CrashReportBatch,
    token: str = Depends(verify_mobile_token)
):
    """Receive crash reports from mobile clients"""
    # Check rate limit
    allowed = await db.check_rate_limit(token, settings.RATE_LIMIT_PER_MINUTE)
    if not allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Rate limit exceeded"
        )
    
    # Save reports
    reports_data = [report.dict() for report in batch.reports]
    count = await db.save_crash_reports(reports_data, token)
    
    return {
        "status": "Finish",
        "message": "Finish",
        "received": count
    }

@app.post("/api/admin/login", response_model=TokenResponse)
async def admin_login(login: LoginRequest):
    """Admin login endpoint"""
    token = authenticate_admin(login.username, login.password)
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password"
        )
    return TokenResponse(access_token=token)

@app.get("/api/admin/reports")
async def get_reports(
    limit: int = 100,
    offset: int = 0,
    error_type: Optional[str] = None,
    platform: Optional[str] = None,
    _: dict = Depends(verify_admin_token)
):
    """Get crash reports (admin only)"""
    reports = await db.get_all_crash_reports(limit, offset, error_type, platform)
    return {"reports": reports}

@app.get("/api/admin/stats")
async def get_stats(_: dict = Depends(verify_admin_token)):
    """Get crash report statistics (admin only)"""
    stats = await db.get_crash_report_stats()
    return stats

# Web UI Routes
@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    """Redirect to login page"""
    return RedirectResponse(url="/login")

@app.get("/login", response_class=HTMLResponse)
async def login_page(request: Request):
    """Login page"""
    return templates.TemplateResponse("login.html", {"request": request})

@app.get("/dashboard", response_class=HTMLResponse)
async def dashboard(request: Request):
    """Dashboard page"""
    return templates.TemplateResponse("dashboard.html", {"request": request})

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
