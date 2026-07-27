# API contract

All timestamps are ISO-8601. The server is authoritative for license state.
Only `valid` permits application startup; `invalid`, `expired`, `locked`, and
`disabled` deny startup.

## License validation

`POST /api/keys/validate` (public validation, no management secret)

```json
{"key":"ABCD1234","client_id":"web-uuid-or-device-id","client_type":"web","project_id":"pos_mobile","company_id":"company-1","shop_id":"shop-1"}
```

`client_id` is required for new clients; `device_id` remains accepted for old
native Flutter builds. Web clients should generate and persist a random UUID
in browser local storage. A successful response contains `valid: true` and
`state: "valid"`; denied responses contain the canonical `state`.

`GET /api/keys/check/{device_id}` remains available for native compatibility.

## Reports

`POST /api/crash-reports` requires `Authorization: Bearer <registered-client-id>`
for frontend reports, or `Authorization: Bearer <BACKEND_REPORT_TOKEN>` for
`pos_backend`. Existing `{errorMessage, stackTrace, deviceInfo, userInfo,
appVersion, platform, timestamp, errorType}` fields are accepted. New fields:
`source`, `backendVersion`, `browser`, `requestId`, `transactionId`,
`project_id`, `company_id`, `shop_id`, and `client_type`.

Server errors should use:

```json
{"reports":[{"source":"pos_backend","error_type":"DatabaseError","error_message":"query failed","stack_trace":"...","backend_version":"2026.07.1","platform":"server","request_id":"req-123","transaction_id":"txn-9","app_version":"n/a","timestamp":"2026-07-26T10:00:00Z"}]}
```

The backend token is configured only in `pos-backend`; it must not be exposed
to a browser or mobile bundle. Payloads are redacted before storage and
reports are rate limited.

## Administration

The existing JWT login and `/api/admin/keys` routes remain protected. Admin
report listing supports `source`, `platform`, `app_version`,
`backend_version`, `error_type`, `request_id`, and `transaction_id` filters.
`POST /api/admin/reports/{id}/status` accepts `error`, `processing`, `fixed`,
or `reviewed`; `DELETE /api/admin/reports/{id}` permanently removes a report.
