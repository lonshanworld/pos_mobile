# Application license and diagnostics backend

This FastAPI service has two deliberately separate responsibilities:

1. Application/project license validation for native Flutter and Flutter Web.
2. Sanitized, authenticated crash/error reporting for Flutter and `pos-backend`.

It is not a POS business-data backend.

## Run

```bash
python -m pip install -r requirements.txt
copy .env.example .env
python main.py
```

Use a strong `SECRET_KEY`, non-default admin credentials, and a private
`BACKEND_REPORT_TOKEN` in production. Put the service behind HTTPS.

See [API.md](API.md) for the contract and [COMPATIBILITY_MIGRATION.md](COMPATIBILITY_MIGRATION.md)
for rollout and online license-validation behavior. Swagger is available at `/docs`.
