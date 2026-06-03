import aiosqlite
from datetime import datetime, timedelta
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
                    client_token TEXT,
                    status TEXT DEFAULT 'error'
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
            
            # API Keys table for key validation feature
            await db.execute('''
                CREATE TABLE IF NOT EXISTS api_keys (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    key TEXT UNIQUE NOT NULL,
                    status TEXT NOT NULL,
                    user_device_id TEXT,
                    created_at TEXT NOT NULL,
                    activated_at TEXT,
                    duration INTEGER
                )
            ''')
            
            # Key Devices registration history table
            await db.execute('''
                CREATE TABLE IF NOT EXISTS api_key_devices (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    key TEXT NOT NULL,
                    device_id TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    UNIQUE(key, device_id)
                )
            ''')
            
            await db.commit()
    
    async def save_crash_reports(
        self,
        reports: List[Dict[str, Any]],
        device_id: str
    ) -> int:
        """Save multiple crash reports to database"""
        async with aiosqlite.connect(self.db_path) as db:
            received_at = datetime.utcnow().isoformat()
            
            for report in reports:
                await db.execute('''
                    INSERT INTO crash_reports (
                        error_message, stack_trace, device_info, user_info,
                        app_version, platform, timestamp, error_type,
                        received_at, client_token, status
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
                    device_id,
                    'error'
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
    
    async def create_api_key(self, key: str, duration: int = 90) -> bool:
        """Create a new API key"""
        async with aiosqlite.connect(self.db_path) as db:
            created_at = datetime.utcnow().isoformat()
            
            await db.execute('''
                INSERT INTO api_keys (key, status, created_at, duration)
                VALUES (?, ?, ?, ?)
            ''', (key, 'active', created_at, duration))
            
            await db.commit()
            return True
    
    async def get_devices_for_key(self, key: str) -> List[Dict[str, Any]]:
        """Get all devices registered to a key"""
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            async with db.execute(
                'SELECT * FROM api_key_devices WHERE key = ? ORDER BY created_at ASC',
                (key,)
            ) as cursor:
                rows = await cursor.fetchall()
                return [dict(row) for row in rows]

    async def delete_key_device(self, key: str, device_id: str) -> bool:
        """Delete a device registration for a key"""
        async with aiosqlite.connect(self.db_path) as db:
            await db.execute(
                'DELETE FROM api_key_devices WHERE key = ? AND device_id = ?',
                (key, device_id)
            )
            
            # Check remaining devices
            db.row_factory = aiosqlite.Row
            async with db.execute(
                'SELECT COUNT(*) as count FROM api_key_devices WHERE key = ?',
                (key,)
            ) as cursor:
                count = (await cursor.fetchone())['count']
            
            if count == 0:
                # Update status back to active in api_keys and clear user_device_id and activated_at
                await db.execute('''
                    UPDATE api_keys
                    SET status = ?, user_device_id = NULL, activated_at = NULL
                    WHERE key = ?
                ''', ('active', key))
            else:
                # Update user_device_id to the remaining device or first device
                async with db.execute(
                    'SELECT device_id FROM api_key_devices WHERE key = ? ORDER BY created_at ASC LIMIT 1',
                    (key,)
                ) as cursor:
                    remaining_row = await cursor.fetchone()
                    if remaining_row:
                        await db.execute('''
                            UPDATE api_keys
                            SET user_device_id = ?
                            WHERE key = ?
                        ''', (remaining_row['device_id'], key))
                        
            await db.commit()
            return True

    async def validate_and_activate_key(self, key: str, device_id: str) -> Optional[Dict[str, Any]]:
        """Validate and activate a key for a device"""
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            
            # Check if key exists
            async with db.execute(
                'SELECT * FROM api_keys WHERE key = ?',
                (key,)
            ) as cursor:
                row = await cursor.fetchone()
            
            if not row:
                return {
                    'valid': False,
                    'error_type': 'invalid_key',
                    'message': 'Invalid key. Please check again.'
                }
            
            # Get registered devices for this key
            devices = await self.get_devices_for_key(key)
            device_ids = [d['device_id'] for d in devices]
            
            current_time = datetime.utcnow().isoformat()
            
            if device_id in device_ids:
                # This device is already registered
                if len(device_ids) > 1:
                    # Duplicate device mapping detected! Even though this device registered, there are other devices!
                    return {
                        'valid': False,
                        'error_type': 'duplicate_device',
                        'message': 'Duplicate Device detect and The app is locked. Please contact Nanonux for more information'
                    }
                else:
                    # Exactly only this device is registered. Valid!
                    # Check expiration if key duration is set
                    if row['activated_at'] and row['duration']:
                        activated_date = datetime.fromisoformat(row['activated_at'])
                        if datetime.utcnow() > activated_date + timedelta(days=row['duration']):
                            return {
                                'valid': False,
                                'error_type': 'expired_key',
                                'message': 'This license activation key has expired.'
                            }
                    
                    return {
                        'valid': True,
                        'key': key,
                        'status': 'used',
                        'activated_at': row['activated_at'] or current_time,
                        'device_id': device_id
                    }
            else:
                # This is a new / unregistered device ID trying to validate!
                # Insert registration for this device
                await db.execute('''
                    INSERT INTO api_key_devices (key, device_id, created_at)
                    VALUES (?, ?, ?)
                ''', (key, device_id, current_time))
                await db.commit()
                
                # Fetch devices again
                devices = await self.get_devices_for_key(key)
                device_ids = [d['device_id'] for d in devices]
                
                if len(device_ids) > 1:
                    # Since there are now multiple devices, it is a duplicate!
                    # Update status to used if needed
                    await db.execute('''
                        UPDATE api_keys 
                        SET status = ?, activated_at = COALESCE(activated_at, ?)
                        WHERE key = ?
                    ''', ('used', current_time, key))
                    await db.commit()
                    
                    return {
                        'valid': False,
                        'error_type': 'duplicate_device',
                        'message': 'Duplicate Device detect and The app is locked. Please contact Nanonux for more information'
                    }
                else:
                    # This is the very first device registered. Bind and validate successfully!
                    await db.execute('''
                        UPDATE api_keys 
                        SET status = ?, user_device_id = ?, activated_at = ?
                        WHERE key = ?
                    ''', ('used', device_id, current_time, key))
                    await db.commit()
                    
                    return {
                        'valid': True,
                        'key': key,
                        'status': 'used',
                        'activated_at': current_time,
                        'device_id': device_id
                    }
    
    async def check_key_status(self, key: str) -> Optional[Dict[str, Any]]:
        """Check the status of a key"""
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            
            async with db.execute(
                'SELECT * FROM api_keys WHERE key = ?',
                (key,)
            ) as cursor:
                row = await cursor.fetchone()
            
            if not row:
                return None
            
            key_data = dict(row)
            key_data['devices'] = await self.get_devices_for_key(key)
            return key_data
    
    async def get_all_api_keys(self) -> List[Dict[str, Any]]:
        """Get all API keys (for admin dashboard)"""
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            
            async with db.execute(
                'SELECT * FROM api_keys ORDER BY created_at DESC'
            ) as cursor:
                rows = await cursor.fetchall()
                keys = [dict(row) for row in rows]
            
            # Fetch registered devices for each key
            for key_obj in keys:
                key_obj['devices'] = await self.get_devices_for_key(key_obj['key'])
                
            return keys
    
    async def get_key_by_device_id(self, device_id: str) -> Optional[Dict[str, Any]]:
        """Check if device has already activated a key"""
        async with aiosqlite.connect(self.db_path) as db:
            db.row_factory = aiosqlite.Row
            
            # Find any key registered to this device in key devices
            async with db.execute(
                'SELECT key FROM api_key_devices WHERE device_id = ? LIMIT 1',
                (device_id,)
            ) as cursor:
                row = await cursor.fetchone()
                
            if not row:
                return None
            
            key = row['key']
            
            async with db.execute(
                'SELECT * FROM api_keys WHERE key = ?',
                (key,)
            ) as cursor:
                key_row = await cursor.fetchone()
                
            if not key_row:
                return None
            
            key_data = dict(key_row)
            # Check if there are duplicate devices for this key
            devices = await self.get_devices_for_key(key)
            if len(devices) > 1:
                key_data['status'] = 'locked'  # Flag it as locked when duplicate is detected
                key_data['error_type'] = 'duplicate_device'
                
            # Check if duration has passed since activation
            if key_data['activated_at'] and key_data['duration']:
                activated_date = datetime.fromisoformat(key_data['activated_at'])
                if datetime.utcnow() > activated_date + timedelta(days=key_data['duration']):
                    return None
            
            return key_data

db = Database()
