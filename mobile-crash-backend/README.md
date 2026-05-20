# Mobile Crash Report Backend

A secure FastAPI backend for collecting and viewing crash reports from your Flutter POS mobile application.

## Features

- 🔒 **Secure API** with token-based authentication for mobile clients
- 👤 **Admin Dashboard** with JWT authentication
- 🚦 **Rate Limiting** to prevent abuse
- 📊 **Statistics Dashboard** showing crash report metrics
- 🗄️ **SQLite Database** for lightweight deployment
- 🔍 **Filtering** by error type and platform

## Setup

### 1. Install Dependencies

```bash
cd mobile-crash-backend
pip install -r requirements.txt
```

### 2. Configure Environment

Create a `.env` file:

```bash
cp .env.example .env
```

Edit `.env` and configure:
- `SECRET_KEY`: A strong random secret key for JWT signing
- `ADMIN_USERNAME`: Admin username for dashboard access
- `ADMIN_PASSWORD`: Admin password (change from default!)
- `MOBILE_API_TOKENS`: Comma-separated list of API tokens for mobile clients

### 3. Run the Server

```bash
python main.py
```

The server will start on `http://localhost:8000`

## Mobile App Configuration

Add these build arguments when running your Flutter app:

```bash
flutter run \
  --dart-define=CRASH_REPORT_URL=http://your-server:8000 \
  --dart-define=CRASH_REPORT_TOKEN=your-mobile-token
```

For production builds:

```bash
flutter build apk \
  --dart-define=CRASH_REPORT_URL=https://your-domain.com \
  --dart-define=CRASH_REPORT_TOKEN=your-mobile-token
```

## API Endpoints

### Mobile Client Endpoints

**POST /api/crash-reports**
- Submit crash reports from mobile app
- Requires: `Authorization: Bearer <mobile-api-token>`
- Rate limited to 10 requests per minute per token
- Request body:
  ```json
  {
    "reports": [
      {
        "errorMessage": "Error description",
        "stackTrace": "Full stack trace",
        "deviceInfo": "Platform information",
        "userInfo": "User context (optional)",
        "appVersion": "1.0.0",
        "platform": "android",
        "timestamp": "2026-05-20T10:30:00Z",
        "errorType": "FlutterError"
      }
    ]
  }
  ```
- Response: `{"status": "Finish", "message": "Finish", "received": 1}`

### Admin Endpoints

**POST /api/admin/login**
- Login to admin dashboard
- Request: `{"username": "admin", "password": "your-password"}`
- Response: `{"access_token": "jwt-token", "token_type": "bearer"}`

**GET /api/admin/reports**
- Get crash reports (requires admin JWT)
- Query params: `limit`, `offset`, `error_type`, `platform`

**GET /api/admin/stats**
- Get crash report statistics (requires admin JWT)

## Dashboard Access

1. Open `http://localhost:8000` in your browser
2. Login with your admin credentials
3. View crash reports and statistics

## Security Features

- **Token Authentication**: Mobile clients use pre-shared API tokens
- **JWT Authentication**: Admin dashboard uses JWT with configurable expiration
- **Rate Limiting**: Per-token rate limiting prevents abuse
- **HTTPS Ready**: Deploy behind reverse proxy for production

## Production Deployment

1. Use a strong `SECRET_KEY`
2. Change default admin credentials
3. Use unique API tokens for each mobile deployment
4. Deploy behind nginx/Apache with HTTPS
5. Set appropriate rate limits
6. Consider using environment variables instead of `.env` file

## Troubleshooting

**Mobile app not syncing:**
- Check network connectivity
- Verify `CRASH_REPORT_URL` and `CRASH_REPORT_TOKEN` are correct
- Check backend logs for authentication errors

**Rate limit errors:**
- Increase `RATE_LIMIT_PER_MINUTE` in config
- Check if multiple devices are using the same token

**Can't login to dashboard:**
- Verify admin credentials in `.env`
- Check browser console for errors
- Ensure backend is running
