from datetime import datetime, timedelta, timezone
from typing import Any, Dict, List, Optional

import aiosqlite

from config import settings
from reporting import fingerprint


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


class Database:
    def __init__(self, db_path: str = settings.DATABASE_URL):
        self.db_path = db_path

    async def init_db(self):
        async with aiosqlite.connect(self.db_path) as conn:
            await conn.executescript("""
                CREATE TABLE IF NOT EXISTS crash_reports (
                    id INTEGER PRIMARY KEY AUTOINCREMENT, error_message TEXT NOT NULL,
                    stack_trace TEXT NOT NULL, device_info TEXT, user_info TEXT,
                    app_version TEXT NOT NULL, platform TEXT NOT NULL, timestamp TEXT NOT NULL,
                    error_type TEXT NOT NULL, received_at TEXT NOT NULL, client_token TEXT,
                    status TEXT DEFAULT 'error'
                );
                CREATE TABLE IF NOT EXISTS rate_limits (
                    token TEXT PRIMARY KEY, request_count INTEGER NOT NULL, window_start TEXT NOT NULL
                );
                CREATE TABLE IF NOT EXISTS api_keys (
                    id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT UNIQUE NOT NULL, status TEXT NOT NULL,
                    user_device_id TEXT, created_at TEXT NOT NULL, activated_at TEXT, duration INTEGER
                );
                CREATE TABLE IF NOT EXISTS api_key_devices (
                    id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT NOT NULL, device_id TEXT NOT NULL,
                    created_at TEXT NOT NULL, UNIQUE(key, device_id)
                );
            """)
            await self._add_columns(conn, "api_keys", {
                "project_id": "TEXT", "company_id": "TEXT", "shop_id": "TEXT",
                "expires_at": "TEXT", "license_state": "TEXT DEFAULT 'valid'",
            })
            await self._add_columns(conn, "crash_reports", {
                "source": "TEXT DEFAULT 'mobile_frontend'", "browser": "TEXT",
                "backend_version": "TEXT", "request_id": "TEXT", "transaction_id": "TEXT",
                "client_type": "TEXT", "project_id": "TEXT", "company_id": "TEXT",
                "shop_id": "TEXT", "fingerprint": "TEXT", "reviewed_at": "TEXT",
            })
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_reports_fingerprint ON crash_reports(fingerprint)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_reports_source ON crash_reports(source)")
            await conn.commit()

    async def _add_columns(self, conn, table: str, columns: Dict[str, str]):
        async with conn.execute(f"PRAGMA table_info({table})") as cursor:
            existing = {row[1] for row in await cursor.fetchall()}
        for name, definition in columns.items():
            if name not in existing:
                await conn.execute(f"ALTER TABLE {table} ADD COLUMN {name} {definition}")

    async def check_rate_limit(self, token: str, limit: int) -> bool:
        window = datetime.now(timezone.utc).replace(second=0, microsecond=0).isoformat()
        async with aiosqlite.connect(self.db_path) as conn:
            async with conn.execute("SELECT request_count, window_start FROM rate_limits WHERE token = ?", (token,)) as cur:
                row = await cur.fetchone()
            if row and row[1] == window and row[0] >= limit:
                return False
            if row and row[1] == window:
                await conn.execute("UPDATE rate_limits SET request_count=request_count+1 WHERE token=?", (token,))
            else:
                await conn.execute("INSERT OR REPLACE INTO rate_limits(token,request_count,window_start) VALUES(?,?,?)", (token, 1, window))
            await conn.commit()
        return True

    async def save_crash_reports(self, reports: List[Dict[str, Any]], credential: str) -> int:
        received = now_iso()
        async with aiosqlite.connect(self.db_path) as conn:
            for report in reports:
                await conn.execute("""INSERT INTO crash_reports
                    (error_message,stack_trace,device_info,user_info,app_version,platform,timestamp,error_type,
                     received_at,client_token,status,source,browser,backend_version,request_id,transaction_id,
                     client_type,project_id,company_id,shop_id,fingerprint)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""", (
                    report.get("error_message", "Unknown error"), report.get("stack_trace", ""),
                    report.get("device_info"), report.get("user_info"), report.get("app_version", "unknown"),
                    report.get("platform", "unknown"), report.get("timestamp", received), report.get("error_type", "Error"),
                    received, credential, "error", report.get("source", "mobile_frontend"), report.get("browser"),
                    report.get("backend_version"), report.get("request_id"), report.get("transaction_id"),
                    report.get("client_type"), report.get("project_id"), report.get("company_id"), report.get("shop_id"),
                    fingerprint(report),
                ))
            await conn.commit()
        return len(reports)

    async def get_all_crash_reports(self, limit=100, offset=0, error_type=None, platform=None, source=None,
                                    app_version=None, backend_version=None, request_id=None, transaction_id=None):
        clauses, params = ["1=1"], []
        for column, value in (("error_type", error_type), ("platform", platform), ("source", source),
                              ("app_version", app_version), ("backend_version", backend_version),
                              ("request_id", request_id), ("transaction_id", transaction_id)):
            if value:
                clauses.append(f"{column} = ?" if column not in ("request_id", "transaction_id") else f"{column} LIKE ?")
                params.append(value if column not in ("request_id", "transaction_id") else f"%{value}%")
        query = f"SELECT * FROM crash_reports WHERE {' AND '.join(clauses)} ORDER BY received_at DESC LIMIT ? OFFSET ?"
        async with aiosqlite.connect(self.db_path) as conn:
            conn.row_factory = aiosqlite.Row
            async with conn.execute(query, (*params, min(max(limit, 1), 500), max(offset, 0))) as cur:
                return [dict(row) for row in await cur.fetchall()]

    async def get_crash_report_stats(self):
        async with aiosqlite.connect(self.db_path) as conn:
            conn.row_factory = aiosqlite.Row
            async with conn.execute("SELECT COUNT(*) count FROM crash_reports") as cur: total = (await cur.fetchone())["count"]
            async with conn.execute("SELECT source, COUNT(*) count FROM crash_reports GROUP BY source") as cur: by_source = {r["source"]: r["count"] for r in await cur.fetchall()}
            async with conn.execute("SELECT error_type, COUNT(*) count FROM crash_reports GROUP BY error_type") as cur: by_type = {r["error_type"]: r["count"] for r in await cur.fetchall()}
            async with conn.execute("SELECT platform, COUNT(*) count FROM crash_reports GROUP BY platform") as cur: by_platform = {r["platform"]: r["count"] for r in await cur.fetchall()}
        return {"total": total, "by_source": by_source, "by_error_type": by_type, "by_platform": by_platform}

    async def delete_crash_report(self, report_id: int) -> bool:
        async with aiosqlite.connect(self.db_path) as conn:
            cur = await conn.execute("DELETE FROM crash_reports WHERE id=?", (report_id,)); await conn.commit()
            return cur.rowcount > 0

    async def update_report_status(self, report_id: int, status: str) -> bool:
        async with aiosqlite.connect(self.db_path) as conn:
            cur = await conn.execute("UPDATE crash_reports SET status=?, reviewed_at=? WHERE id=?", (status, now_iso(), report_id)); await conn.commit()
            return cur.rowcount > 0

    async def _key_row(self, key: str):
        async with aiosqlite.connect(self.db_path) as conn:
            conn.row_factory = aiosqlite.Row
            async with conn.execute("SELECT * FROM api_keys WHERE key=?", (key,)) as cur: row = await cur.fetchone()
            return dict(row) if row else None

    async def validate_and_activate_key(self, key: str, client_id: str, project_id=None, company_id=None, shop_id=None, client_type="native"):
        row = await self._key_row(key)
        if not row: return {"valid": False, "state": "invalid", "error_type": "invalid_key", "message": "Invalid license key."}
        state = (row.get("license_state") or ("locked" if row.get("status") == "locked" else "valid")).lower()
        if state in {"locked", "disabled"}: return {"valid": False, "state": state, "message": f"License is {state}."}
        expires = row.get("expires_at")
        if expires is None and row.get("activated_at") and row.get("duration"):
            expires = (datetime.fromisoformat(row["activated_at"]) + timedelta(days=row["duration"])).isoformat()
        if expires and datetime.now(timezone.utc) >= datetime.fromisoformat(expires.replace("Z", "+00:00")):
            return {"valid": False, "state": "expired", "error_type": "expired_key", "message": "This license has expired."}
        if row.get("project_id") and project_id and row["project_id"] != project_id:
            return {"valid": False, "state": "invalid", "message": "License is not issued for this project."}
        async with aiosqlite.connect(self.db_path) as conn:
            async with conn.execute("SELECT device_id FROM api_key_devices WHERE key=?", (key,)) as cur: devices = [r[0] for r in await cur.fetchall()]
            if len(devices) > 1 or (devices and client_id not in devices):
                await conn.execute("UPDATE api_keys SET license_state='locked' WHERE key=?", (key,)); await conn.commit()
                return {"valid": False, "state": "locked", "error_type": "duplicate_device", "message": "License is locked for another client."}
            current = now_iso()
            if not devices:
                await conn.execute("INSERT INTO api_key_devices(key,device_id,created_at) VALUES(?,?,?)", (key, client_id, current))
                await conn.execute("UPDATE api_keys SET status='used', user_device_id=?, activated_at=?, project_id=COALESCE(project_id,?), company_id=COALESCE(company_id,?), shop_id=COALESCE(shop_id,?), license_state='valid' WHERE key=?", (client_id,current,project_id,company_id,shop_id,key))
                await conn.commit()
        return {"valid": True, "state": "valid", "status": "used", "key": key, "activated_at": row.get("activated_at") or now_iso(), "client_id": client_id}

    async def get_key_by_device_id(self, client_id):
        async with aiosqlite.connect(self.db_path) as conn:
            conn.row_factory = aiosqlite.Row
            async with conn.execute("SELECT k.* FROM api_keys k JOIN api_key_devices d ON d.key=k.key WHERE d.device_id=? LIMIT 1", (client_id,)) as cur: row = await cur.fetchone()
            if not row:
                return None
            result = dict(row)
            async with conn.execute("SELECT COUNT(*) FROM api_key_devices WHERE key=?", (result["key"],)) as cur:
                if (await cur.fetchone())[0] > 1:
                    result["license_state"] = "locked"
            return result

    async def create_api_key(self, key, duration=90, project_id=None, company_id=None, shop_id=None):
        async with aiosqlite.connect(self.db_path) as conn:
            await conn.execute("INSERT INTO api_keys(key,status,created_at,duration,project_id,company_id,shop_id,license_state) VALUES(?,?,?,?,?,?,?,?)", (key,"active",now_iso(),duration,project_id,company_id,shop_id,"valid")); await conn.commit()
        return True

    async def get_all_api_keys(self):
        async with aiosqlite.connect(self.db_path) as conn:
            conn.row_factory = aiosqlite.Row
            async with conn.execute("SELECT * FROM api_keys ORDER BY created_at DESC") as cur: return [dict(r) for r in await cur.fetchall()]

    async def delete_key_device(self, key, client_id):
        async with aiosqlite.connect(self.db_path) as conn:
            cur = await conn.execute("DELETE FROM api_key_devices WHERE key=? AND device_id=?", (key,client_id)); await conn.commit(); return cur.rowcount > 0

    async def get_key_by_device(self, client_id): return await self.get_key_by_device_id(client_id)


db = Database()
