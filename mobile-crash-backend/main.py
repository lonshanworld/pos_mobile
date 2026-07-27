import secrets
import string
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

import aiosqlite
import uvicorn
from fastapi import Depends, FastAPI, HTTPException, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel, ConfigDict, Field
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from auth import authenticate_admin, verify_admin_token, verify_report_token
from config import settings
from database import db
from reporting import sanitize_report

app = FastAPI(title="Application License and Diagnostics Backend", version="2.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=False, allow_methods=["*"], allow_headers=["*"])
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
templates = Jinja2Templates(directory="templates")


class CrashReport(BaseModel):
    model_config = ConfigDict(populate_by_name=True, extra="allow")
    error_message: str = Field("Unknown error", alias="errorMessage")
    stack_trace: str = Field("", alias="stackTrace")
    error_type: str = Field("Error", alias="errorType")
    app_version: str = Field("unknown", alias="appVersion")
    backend_version: Optional[str] = Field(None, alias="backendVersion")
    platform: str = "unknown"
    browser: Optional[str] = None
    device_info: Optional[Any] = Field(None, alias="deviceInfo")
    user_info: Optional[Any] = Field(None, alias="userInfo")
    request_id: Optional[str] = Field(None, alias="requestId")
    transaction_id: Optional[str] = Field(None, alias="transactionId")
    project_id: Optional[str] = None
    company_id: Optional[str] = None
    shop_id: Optional[str] = None
    client_type: Optional[str] = None
    source: str = "mobile_frontend"
    timestamp: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())


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
    device_id: Optional[str] = None
    client_id: Optional[str] = None
    project_id: Optional[str] = None
    company_id: Optional[str] = None
    shop_id: Optional[str] = None
    client_type: str = "native"


class GenerateKeyRequest(BaseModel):
    expires_days: Optional[int] = 90
    project_id: Optional[str] = None
    company_id: Optional[str] = None
    shop_id: Optional[str] = None


@app.on_event("startup")
async def startup_event():
    await db.init_db()


@app.post("/api/crash-reports")
@limiter.limit(f"{settings.RATE_LIMIT_PER_MINUTE}/minute")
async def receive_crash_reports(request: Request, batch: CrashReportBatch, credential: str = Depends(verify_report_token)):
    if not batch.reports or len(batch.reports) > settings.MAX_REPORTS_PER_REQUEST:
        raise HTTPException(422, f"reports must contain 1-{settings.MAX_REPORTS_PER_REQUEST} items")
    reports = []
    for model in batch.reports:
        report = model.model_dump(by_alias=False)
        if credential == "pos_backend": report["source"] = "pos_backend"
        elif report["source"] not in {"mobile_frontend", "web_frontend"}: report["source"] = "mobile_frontend"
        reports.append(sanitize_report(report, settings.MAX_FIELD_LENGTH))
    if not await db.check_rate_limit(credential, settings.RATE_LIMIT_PER_MINUTE):
        raise HTTPException(429, "Rate limit exceeded")
    count = await db.save_crash_reports(reports, credential)
    return {"status": "Finish", "message": "Finish", "received": count}


@app.post("/api/admin/login", response_model=TokenResponse)
async def admin_login(login: LoginRequest):
    token = authenticate_admin(login.username, login.password)
    if not token: raise HTTPException(401, "Incorrect username or password")
    return TokenResponse(access_token=token)


@app.get("/api/admin/reports")
async def get_reports(limit: int = 100, offset: int = 0, error_type: Optional[str] = None, platform: Optional[str] = None,
                      source: Optional[str] = None, app_version: Optional[str] = None, backend_version: Optional[str] = None,
                      request_id: Optional[str] = None, transaction_id: Optional[str] = None, _: dict = Depends(verify_admin_token)):
    return {"reports": await db.get_all_crash_reports(limit, offset, error_type, platform, source, app_version, backend_version, request_id, transaction_id)}


@app.get("/api/admin/stats")
async def get_stats(_: dict = Depends(verify_admin_token)): return await db.get_crash_report_stats()


@app.delete("/api/admin/reports/{report_id}")
async def delete_report(report_id: int, _: dict = Depends(verify_admin_token)): return {"success": await db.delete_crash_report(report_id)}


@app.get("/api/admin/reports/{report_id}")
async def get_report_detail(report_id: int, _: dict = Depends(verify_admin_token)):
    async with aiosqlite.connect(settings.DATABASE_URL) as conn:
        conn.row_factory = aiosqlite.Row
        async with conn.execute("SELECT * FROM crash_reports WHERE id=?", (report_id,)) as cur: row = await cur.fetchone()
    if not row: raise HTTPException(404, "Report not found")
    return dict(row)


@app.post("/api/admin/reports/{report_id}/status")
async def update_report_status(report_id: int, status_update: Dict[str, str], _: dict = Depends(verify_admin_token)):
    new_status = status_update.get("status")
    if new_status not in {"error", "processing", "fixed", "reviewed"}: raise HTTPException(400, "Invalid status")
    return {"success": await db.update_report_status(report_id, new_status)}


@app.post("/api/keys/validate")
async def validate_key(request: KeyValidationRequest):
    client_id = request.client_id or request.device_id
    if not client_id: raise HTTPException(422, "client_id or device_id is required")
    return await db.validate_and_activate_key(request.key, client_id, request.project_id, request.company_id, request.shop_id, request.client_type)


@app.get("/api/keys/check/{device_id}")
async def check_device_key(device_id: str):
    info = await db.get_key_by_device_id(device_id)
    if not info: return {"has_key": False}
    state = info.get("license_state") or ("locked" if info.get("status") == "locked" else "valid")
    return {"has_key": state == "valid", "state": state, "locked": state == "locked", "activated_at": info.get("activated_at")}


@app.delete("/api/admin/keys/{key}/devices/{device_id}")
async def delete_key_device(key: str, device_id: str, _: dict = Depends(verify_admin_token)):
    if not await db.delete_key_device(key, device_id):
        raise HTTPException(404, "Device not found")
    return {"status": "success", "message": "Device removed successfully"}


@app.post("/api/admin/keys/generate")
async def generate_key(request: GenerateKeyRequest, _: dict = Depends(verify_admin_token)):
    new_key = "".join(secrets.choice(string.ascii_uppercase + string.digits) for _ in range(8))
    await db.create_api_key(new_key, request.expires_days, request.project_id, request.company_id, request.shop_id)
    return {"status": "success", "key": new_key, "expires_days": request.expires_days}


@app.get("/api/admin/keys")
async def get_all_keys(_: dict = Depends(verify_admin_token)):
    keys = await db.get_all_api_keys()
    return {"total": len(keys), "active": sum(k.get("status") == "active" for k in keys), "used": sum(k.get("status") == "used" for k in keys), "keys": keys}


@app.get("/report/{report_id}", response_class=HTMLResponse)
async def report_detail_page(request: Request, report_id: int): return templates.TemplateResponse("report_detail.html", {"request": request})
@app.get("/", response_class=HTMLResponse)
async def root(request: Request): return RedirectResponse(url="/login")
@app.get("/login", response_class=HTMLResponse)
async def login_page(request: Request): return templates.TemplateResponse("login.html", {"request": request})
@app.get("/dashboard", response_class=HTMLResponse)
async def dashboard(request: Request): return templates.TemplateResponse("dashboard.html", {"request": request})
@app.get("/health")
async def health_check(): return {"status": "healthy"}


if __name__ == "__main__": uvicorn.run("main:app", host="0.0.0.0", port=12500)
