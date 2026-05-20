import aiosqlite
from datetime import datetime
from typing import Optional, List, Dict, Any
from config import settings

class Database:
    def __init__(self, db_path: str = settings.DATABASE_URL):
        self.db_path = db_path
    
    async def init_db(self):
        """Initialize database with required tables"""
        async with aiosqlite.connect(self.db_path) as db:
            # Crash reports table
            await db.execute('''
                CREATE TABLE IF NOT EXISTS crash_reports (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    error_message TEXT NOT NULL,
                    stack_trace TEXT NOT NULL,
                    device_info TEXT,
                    user_info TEXT,
                    app_version TEXT NOT NULL,
                    platform TEXT NOT NULL,
                    timestamp TEXT NOT NULL,
                    error_type TEXT NOT NULL,
                    received_at TEXT NOT NULL,
                    client_token TEXT
                )
            ''')
            
            # Rate limiting table
            await db.execute('''
                CREATE TABLE IF NOT EXISTS rate_limits (
                    token TEXT PRIMARY KEY,
                    request_count INTEGER NOT NULL,
                    window_start TEXT NOT NULL
                )
            ''')
            
            await db.commit()
    
    async def save_crash_reports(
        self,
        reports: List[Dict[str, Any]],
        client_token: str
    ) -> int:
        """Save multiple crash reports to database"""
        async with aiosqlite.connect(self.db_path) as db:
            received_at = datetime.utcnow().isoformat()
            
            for report in reports:
                await db.execute('''
                    INSERT INTO crash_reports (
                        error_message, stack_trace, device_info, user_info,
                        app_version, platform, timestamp, error_type,
                        received_at, client_token
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    report.get('errorMessage'),
                    report.get('stackTrace'),
                    report.get('deviceInfo'),
                    report.get('userInfo'),
                    report.get('appVersion'),
                    report.get('platform'),
                    report.get('timestamp'),
                    report.get('errorType'),
                    received_at,
                    client_token
                ))
            
            await db.commit()
            return len(reports)
    
    async def get_all_crash_reports(
        self,
        limit: int = 100,
        offset: int = 0,
        error_type: Optional[str] = None,
        platform: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Get crash reports with optional filtering"""
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            
            query = 'SELECT * FROM crash_reports WHERE 1=1'
            params = []
            
            if error_type:
                query += ' AND error_type = ?'
                params.append(error_type)
            
            if platform:
                query += ' AND platform = ?'
                params.append(platform)
            
            query += ' ORDER BY received_at DESC LIMIT ? OFFSET ?'
            params.extend([limit, offset])
            
            async with db.execute(query, params) as cursor:
                rows = await cursor.fetchall()
                return [dict(row) for row in rows]
    
    async def get_crash_report_stats(self) -> Dict[str, Any]:
        """Get statistics about crash reports"""
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            
            # Total count
            async with db.execute('SELECT COUNT(*) as count FROM crash_reports') as cursor:
                total = (await cursor.fetchone())['count']
            
            # Count by error type
            async with db.execute('''
                SELECT error_type, COUNT(*) as count
                FROM crash_reports
                GROUP BY error_type
            ''') as cursor:
                by_type = {row['error_type']: row['count'] for row in await cursor.fetchall()}
            
            # Count by platform
            async with db.execute('''
                SELECT platform, COUNT(*) as count
                FROM crash_reports
                GROUP BY platform
            ''') as cursor:
                by_platform = {row['platform']: row['count'] for row in await cursor.fetchall()}
            
            # Recent reports (last 24 hours)
            async with db.execute('''
                SELECT COUNT(*) as count FROM crash_reports
                WHERE datetime(received_at) > datetime('now', '-1 day')
            ''') as cursor:
                recent_24h = (await cursor.fetchone())['count']
            
            return {
                'total': total,
                'by_error_type': by_type,
                'by_platform': by_platform,
                'recent_24h': recent_24h
            }
    
    async def check_rate_limit(self, token: str, limit: int) -> bool:
        """Check if token has exceeded rate limit"""
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            now = datetime.utcnow()
            window_start = now.replace(second=0, microsecond=0).isoformat()
            
            async with db.execute(
                'SELECT * FROM rate_limits WHERE token = ?',
                (token,)
            ) as cursor:
                row = await cursor.fetchone()
            
            if row:
                if row['window_start'] == window_start:
                    if row['request_count'] >= limit:
                        return False
                    
                    await db.execute(
                        'UPDATE rate_limits SET request_count = request_count + 1 WHERE token = ?',
                        (token,)
                    )
                else:
                    await db.execute(
                        'UPDATE rate_limits SET request_count = 1, window_start = ? WHERE token = ?',
                        (window_start, token)
                    )
            else:
                await db.execute(
                    'INSERT INTO rate_limits (token, request_count, window_start) VALUES (?, 1, ?)',
                    (token, window_start)
                )
            
            await db.commit()
            return True

db = Database()
