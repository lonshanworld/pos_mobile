import asyncio
import pytest
from fastapi.testclient import TestClient
from config import settings
from database import db
from main import app

@pytest.fixture()
def client(tmp_path):
    db.db_path = str(tmp_path / "test.db")
    settings.BACKEND_REPORT_TOKEN = "server-secret"
    asyncio.run(db.init_db())
    with TestClient(app) as test_client:
        yield test_client

def make_key(name="KEY-1"):
    asyncio.run(db.create_api_key(name))

def test_license_states_and_native_client(client):
    make_key("VALID")
    result = client.post("/api/keys/validate", json={"key": "VALID", "device_id": "android-1"})
    assert result.status_code == 200 and result.json()["state"] == "valid"
    for state in ("locked", "disabled"):
        make_key(state.upper())
        asyncio.run(set_state(state.upper(), state))
        response = client.post("/api/keys/validate", json={"key": state.upper(), "device_id": "android-x"})
        assert response.json()["state"] == state and response.json()["valid"] is False
    make_key("EXPIRED")
    asyncio.run(set_expiry("EXPIRED"))
    response = client.post("/api/keys/validate", json={"key": "EXPIRED", "device_id": "android-expired"})
    assert response.json()["state"] == "expired" and response.json()["valid"] is False

async def set_state(key, state):
    import aiosqlite
    async with aiosqlite.connect(db.db_path) as conn:
        await conn.execute("UPDATE api_keys SET license_state=? WHERE key=?", (state, key))
        await conn.commit()

async def set_expiry(key):
    import aiosqlite
    async with aiosqlite.connect(db.db_path) as conn:
        await conn.execute("UPDATE api_keys SET expires_at=? WHERE key=?", ("2020-01-01T00:00:00+00:00", key))
        await conn.commit()

def test_web_client_and_unauthorized_report(client):
    make_key("WEB")
    assert client.post("/api/keys/validate", json={"key": "WEB", "client_id": "web-uuid", "client_type": "web"}).json()["valid"]
    assert client.post("/api/crash-reports", json={"reports": []}).status_code in (401, 403)

def test_mobile_report_is_sanitized_and_admin_filters(client):
    make_key("REPORT")
    client.post("/api/keys/validate", json={"key": "REPORT", "device_id": "android-report"})
    response = client.post("/api/crash-reports", headers={"Authorization": "Bearer android-report"}, json={"reports": [{
        "errorMessage": "password=do-not-store", "stackTrace": "Bearer abc-secret", "errorType": "AuthError",
        "appVersion": "1.2.3", "platform": "android", "requestId": "req-7", "source": "mobile_frontend",
    }]})
    assert response.status_code == 200 and response.json()["received"] == 1
    login = client.post("/api/admin/login", json={"username": settings.ADMIN_USERNAME, "password": settings.ADMIN_PASSWORD})
    token = login.json()["access_token"]
    reports = client.get("/api/admin/reports", params={"request_id": "req-7", "source": "mobile_frontend"}, headers={"Authorization": f"Bearer {token}"})
    assert reports.status_code == 200 and len(reports.json()["reports"]) == 1
    row = reports.json()["reports"][0]
    assert "[REDACTED]" in row["error_message"] and "[REDACTED]" in row["stack_trace"]

def test_backend_report_submission(client):
    response = client.post("/api/crash-reports", headers={"Authorization": "Bearer server-secret"}, json={"reports": [{
        "source": "mobile_frontend", "error_message": "server failed", "stack_trace": "trace",
        "error_type": "RuntimeError", "app_version": "n/a", "backend_version": "2.1", "platform": "server",
    }]})
    assert response.status_code == 200
    row = asyncio.run(last_report())
    assert row["source"] == "pos_backend"

async def last_report():
    import aiosqlite
    async with aiosqlite.connect(db.db_path) as conn:
        conn.row_factory = aiosqlite.Row
        async with conn.execute("SELECT * FROM crash_reports ORDER BY id DESC LIMIT 1") as cur:
            return dict(await cur.fetchone())
