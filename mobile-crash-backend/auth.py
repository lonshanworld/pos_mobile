from datetime import datetime, timedelta
from typing import Optional
import secrets
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import HTTPException, Security, status, Request
from database import db
from config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against a hash"""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Hash a password"""
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

def verify_token(token: str) -> dict:
    """Verify and decode a JWT token"""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

async def verify_mobile_token(
    request: Request,
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> str:
    """Verify a registered frontend license client (legacy device IDs remain valid)."""
    device_id = credentials.credentials
    key_info = await db.get_key_by_device_id(device_id)
    if not key_info:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid device ID or not registered",
            headers={"WWW-Authenticate": "Bearer"},
        )
    state = (key_info.get("license_state") or ("locked" if key_info.get("status") == "locked" else "valid")).lower()
    if state != "valid":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=f"License is {state}")
    return device_id


async def verify_report_token(
    credentials: HTTPAuthorizationCredentials = Security(security),
) -> str:
    """Authenticate either a registered frontend client or the server token."""
    token = credentials.credentials
    if settings.BACKEND_REPORT_TOKEN and secrets.compare_digest(token, settings.BACKEND_REPORT_TOKEN):
        return "pos_backend"
    key_info = await db.get_key_by_device_id(token)
    if not key_info:
        raise HTTPException(status_code=401, detail="Invalid report credential", headers={"WWW-Authenticate": "Bearer"})
    state = (key_info.get("license_state") or ("locked" if key_info.get("status") == "locked" else "valid")).lower()
    if state != "valid":
        raise HTTPException(status_code=403, detail=f"License is {state}")
    return token

def verify_admin_token(credentials: HTTPAuthorizationCredentials = Security(security)) -> dict:
    """Verify admin JWT token"""
    token = credentials.credentials
    payload = verify_token(token)
    if payload.get("sub") != settings.ADMIN_USERNAME:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to access this resource"
        )
    return payload

def authenticate_admin(username: str, password: str) -> Optional[str]:
    """Authenticate admin user and return access token"""
    if username == settings.ADMIN_USERNAME and password == settings.ADMIN_PASSWORD:
        access_token = create_access_token(
            data={"sub": username},
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        return access_token
    return None
