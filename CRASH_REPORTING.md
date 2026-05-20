# Crash Reporting Integration Guide

This document explains how the crash reporting system works in the POS Mobile application.

## Overview

The crash reporting system captures all Flutter and platform errors, stores them locally in SQLite, and syncs them to a backend server when online. This ensures no crash data is lost even in offline-first scenarios.

## Architecture

```
Flutter App Error → Local SQLite DB → Periodic Sync → FastAPI Backend → Web Dashboard
```

## Components

### 1. Mobile Side (Flutter)

**Files Created/Modified:**
- `lib/models/crash_report_model.dart` - Data model for crash reports
- `lib/database/crash_report_DB/crash_report_DBStorage.dart` - SQLite storage layer
- `lib/database/crash_report_DB/crash_report_DBService.dart` - Service layer
- `lib/controller/DB_helper.dart` - Database façade (added crash report methods)
- `lib/utils/crash_reporter.dart` - Global error handler (enhanced with local storage)
- `lib/services/crash_report_api_service.dart` - API client for syncing reports
- `lib/services/crash_report_sync_manager.dart` - Automatic sync with connectivity monitoring
- `lib/main.dart` - Integrated sync manager initialization

**Dependencies Added:**
```yaml
dependencies:
  package_info_plus: ^8.1.4      # For app version detection
  http: ^1.2.2                   # For API communication
  connectivity_plus: ^6.1.1      # For network connectivity monitoring
```

### 2. Backend (Python FastAPI)

Located in: `mobile-crash-backend/`

**Features:**
- ✅ Token-based authentication for mobile clients
- ✅ JWT authentication for admin dashboard
- ✅ Rate limiting (10 requests/minute per token)
- ✅ SQLite database for report storage
- ✅ Web UI for viewing and filtering reports
- ✅ Statistics dashboard

## How It Works

### Error Capture

When an error occurs in the app:

1. `CrashReporter` intercepts the error (Flutter or Platform error)
2. Creates a `CrashReportModel` with:
   - Error message and stack trace
   - App version and platform
   - Device info and timestamp
   - Error type (FlutterError/PlatformError)
3. Saves to local SQLite with `isSynced = false`
4. Optionally sends to Sentry if configured

### Syncing to Backend

**Automatic Syncing (Recommended):**

The app automatically syncs crash reports in the following scenarios:
- ✅ **On app startup** - If device is online
- ✅ **Device comes online** - When connectivity is restored
- ✅ **App resume** - When app returns to foreground
- ✅ **Periodic checks** - Every 5 minutes while online

This is handled by `CrashReportSyncManager` which is automatically initialized in `main.dart`. No additional code needed!

**Manual Syncing (Optional):**

You can also trigger sync manually (e.g., from a button):

```dart
import 'package:pos_mobile/services/crash_report_sync_manager.dart';

// Trigger manual sync
await CrashReportSyncManager.instance.manualSync();

// Check if device is online
final isOnline = CrashReportSyncManager.instance.isOnline;
```

**Sync Process:**
1. Checks connectivity status (skips if offline)
2. Checks if there are unsynced reports (`isSynced = false`)
3. If none, returns immediately (no network call)
4. Sends all unsynced reports in a single API call
5. On success ("Finish" response):
   - Marks reports as synced (`isSynced = true`)
   - Deletes synced reports to free up space
6. Handles offline/rate-limit gracefully (doesn't crash)

### Integration (Already Done!)

The crash reporting system is **fully automatic** and requires no additional setup. Everything is initialized in `main.dart`:

1. **Error Capture**: Automatically catches all Flutter and platform errors
2. **Local Storage**: Saves to SQLite immediately
3. **Auto-Sync**: Monitors connectivity and syncs when online

**What happens automatically:**
- Errors are saved locally as they occur
- On app startup, if online, unsynced reports are sent
- When device comes online, pending reports are synced
- When app resumes from background, sync is attempted
- Every 5 minutes while online, sync is checked

**No code needed!** Just configure the environment variables when building.

## Configuration

### Mobile App

Set environment variables when building/running:

```bash
# Development
flutter run \
  --dart-define=CRASH_REPORT_URL=http://localhost:8000 \
  --dart-define=CRASH_REPORT_TOKEN=your-dev-token

# Production
flutter build apk --release \
  --dart-define=CRASH_REPORT_URL=https://crash-reports.yourdomain.com \
  --dart-define=CRASH_REPORT_TOKEN=your-prod-token
```

### Backend

1. Set up the backend (see `mobile-crash-backend/README.md`)
2. Configure `.env` with admin credentials and API tokens
3. Start server: `python main.py`
4. Access dashboard at `http://localhost:8000`

## Security

- **Mobile→Backend**: Uses Bearer token authentication
- **Admin Dashboard**: Uses JWT with username/password
- **Rate Limiting**: 10 requests per minute per mobile token
- **HTTPS**: Deploy behind reverse proxy in production

## Database Schema

**Mobile (SQLite):**
```sql
CREATE TABLE crash_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    errorMessage TEXT NOT NULL,
    stackTrace TEXT NOT NULL,
    deviceInfo TEXT,
    userInfo TEXT,
    appVersion TEXT NOT NULL,
    platform TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    errorType TEXT NOT NULL,
    isSynced INTEGER NOT NULL DEFAULT 0
);
```

**Backend (SQLite):**
```sql
CREATE TABLE crash_reports (
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
);
```

## Monitoring

Check crash report count:

```dart
final count = await DBHelper.getUnsyncedCrashReportCount();
print('Unsynced crash reports: $count');
```

View all unsynced reports:

```dart
final reports = await DBHelper.getUnsyncedCrashReports();
for (var report in reports) {
  print('${report.errorType}: ${report.errorMessage}');
}
```

## Troubleshooting

**Reports not syncing:**
- Check if `CRASH_REPORT_TOKEN` is set
- Verify backend is running and accessible
- Check device has internet connection
- Look for error messages in console (cusDebugPrint)

**Too many unsynced reports:**
- Reports accumulate if device is offline for long periods
- Consider calling `DBHelper.deleteSyncedCrashReports()` manually
- Or adjust retention policy

**Backend rejecting reports:**
- Verify token matches one in `MOBILE_API_TOKENS`
- Check if rate limit is exceeded (429 error)
- Ensure request format matches expected schema
