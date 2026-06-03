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
import secrets
import string
import aiosqlite

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

class KeyValidationRequest(BaseModel):
    key: str
    device_id: str

class KeyValidationResponse(BaseModel):
    valid: bool
    message: str
    activated_at: Optional[str] = None

class GenerateKeyRequest(BaseModel):
    expires_days: Optional[int] = 90

class KeyInfo(BaseModel):
    key: str
    status: str
    user_device_id: Optional[str]
    created_at: str
    activated_at: Optional[str]
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
    device_id: str = Depends(verify_mobile_token)
):
    """Receive crash reports from mobile clients"""
    # Check rate limit
    allowed = await db.check_rate_limit(device_id, settings.RATE_LIMIT_PER_MINUTE)
    if not allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Rate limit exceeded"
        )
    
    # Save reports
    reports_data = [report.dict() for report in batch.reports]
    count = await db.save_crash_reports(reports_data, device_id)
    
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

@app.get("/api/admin/reports/{report_id}")
async def get_report_detail(report_id: int, _: dict = Depends(verify_admin_token)):
    """Get crash report detail (admin only)"""
    async with aiosqlite.connect(settings.DATABASE_URL) as db:
        db.row_factory = aiosqlite.Row
        async with db.execute('SELECT * FROM crash_reports WHERE id = ?', (report_id,)) as cursor:
            row = await cursor.fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="Report not found")
            return dict(row)

@app.post("/api/admin/reports/{report_id}/status")
async def update_report_status(
    report_id: int,
    status_update: dict,
    _: dict = Depends(verify_admin_token)
):
    """Update crash report status (admin only)"""
    new_status = status_update.get("status")
    if new_status not in ["error", "processing", "fixed"]:
        raise HTTPException(status_code=400, detail="Invalid status")
    
    async with aiosqlite.connect(settings.DATABASE_URL) as db:
        await db.execute('UPDATE crash_reports SET status = ? WHERE id = ?', (new_status, report_id))
        await db.commit()
    return {"status": "success"}

@app.get("/report/{report_id}", response_class=HTMLResponse)
async def report_detail_page(request: Request, report_id: int):
    """Report detail page"""
    return templates.TemplateResponse("report_detail.html", {"request": request})

# Key Management API Routes
@app.post("/api/keys/validate", response_model=KeyValidationResponse)
async def validate_key(request: KeyValidationRequest):
    """Validate and activate a key on a device"""
    result = await db.validate_and_activate_key(request.key, request.device_id)
    
    if result:
        return KeyValidationResponse(
            valid=result.get('valid', False),
            message=result.get('message', ''),
            activated_at=result.get('activated_at')
        )
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or already used key"
        )

@app.get("/api/keys/check/{device_id}")
async def check_device_key(device_id: str):
    """Check if a device has already activated a key"""
    key_info = await db.get_key_by_device_id(device_id)
    
    if key_info:
        if key_info.get('status') == 'locked' or key_info.get('error_type') == 'duplicate_device':
            return {
                "has_key": False,
                "locked": True,
                "message": "Duplicate Device detect and The app is locked. Please contact Nanonux for more information"
            }
        return {
            "has_key": True,
            "activated_at": key_info['activated_at']
        }
    else:
        return {"has_key": False}

@app.delete("/api/admin/keys/{key}/devices/{device_id}")
async def delete_key_device(key: str, device_id: str, _: dict = Depends(verify_admin_token)):
    """Delete a registered device for a key (admin only)"""
    success = await db.delete_key_device(key, device_id)
    if success:
        return {"status": "success", "message": "Device removed successfully"}
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to remove device"
        )

@app.post("/api/admin/keys/generate", response_model=dict)
async def generate_key(request: GenerateKeyRequest, _: dict = Depends(verify_admin_token)):
    """Generate a new key (admin only)"""
    # Generate a random key: 8 random characters (alphanumeric)
    characters = string.ascii_uppercase + string.digits
    new_key = ''.join(secrets.choice(characters) for _ in range(8))
    
    success = await db.create_api_key(new_key, request.expires_days)
    
    if success:
        return {
            "status": "success",
            "key": new_key,
            "expires_days": request.expires_days
        }
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate key"
        )

@app.get("/api/admin/keys", response_model=dict)
async def get_all_keys(_: dict = Depends(verify_admin_token)):
    """Get all keys (admin only)"""
    keys = await db.get_all_api_keys()
    active_count = sum(1 for k in keys if k['status'] == 'active')
    used_count = sum(1 for k in keys if k['status'] == 'used')
    
    return {
        "total": len(keys),
        "active": active_count,
        "used": used_count,
        "keys": keys
    }

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
    uvicorn.run("main:app", host="0.0.0.0", port=12500, reload=True)
