# Compatibility and migration note

## Current contract observed

- Native Flutter calls `POST /api/keys/validate` with `{key, device_id}` and
  calls `GET /api/keys/check/{device_id}`.
- Native crash sync calls `POST /api/crash-reports` with a bearer token equal
  to the registered device ID and expects `status` or `message` to be
  `Finish`.
- The dashboard uses the existing admin JWT routes and HTML pages.

## Refactor compatibility

The two legacy key routes and the crash-report route remain available. Legacy
requests are interpreted as `mobile_frontend` requests. Existing SQLite tables
are migrated additively at startup; existing keys and reports are retained.
The old `api_keys.status` values (`active`, `used`) remain readable, while all
new validation responses expose a canonical license state.

New clients should send `project_id`, `company_id`, `shop_id`, `client_type`,
and a stable `client_id`. Native clients may use their existing device ID.
Flutter Web should generate a random UUID once and persist it in browser local
storage; it is a client installation identifier, not a hardware/device ID.

## License behavior

The server is authoritative whenever it can be reached. `valid` is the only
state that permits application startup. `invalid`, `expired`, `locked`, and
`disabled` deny access on the next successful validation. Offline license
behavior is intentionally owned by the mobile application: it may retain its
local state while disconnected and must automatically retry the validation API
when connectivity returns. This backend does not issue an offline grace
period or bypass token.

## Crash reporting migration

`POST /api/crash-reports` accepts both the legacy camelCase fields and the new
metadata fields. New server submissions use `source=pos_backend` and a
dedicated `BACKEND_REPORT_TOKEN`; frontend submissions use a registered
license bearer credential. Payloads are sanitized server-side. Passwords,
tokens, payment-card data, and common credential fields are redacted before
storage. Reports are grouped by a deterministic fingerprint.

License-management routes under `/api/admin/keys` remain admin-JWT protected.
The public validation routes expose only validation results and safe metadata;
they never expose management secrets.

## Rollout

1. Deploy this backend and allow startup migrations to complete.
2. Keep existing Flutter builds pointed at the same base URL; they continue to
   use the legacy routes.
3. Configure `BACKEND_REPORT_TOKEN` for `pos-backend` and send the documented
   server-report schema.
4. Update Flutter Web to persist a browser `client_id` and send the new
   fields. No Flutter source change is included in this backend refactor.

The current Flutter client already retries/report-syncs when connectivity is
available. Updating its startup retry policy is intentionally deferred to the
Flutter refactor; this backend does not impose an offline timer.
