"""Validation and redaction helpers for untrusted diagnostic payloads."""
import hashlib
import json
import re
from typing import Any, Dict

SENSITIVE_KEY = re.compile(
    r"(password|passwd|secret|token|access[_-]?token|refresh[_-]?token|authorization|api[_-]?key|card|cvv|cvc|pan|iban)",
    re.IGNORECASE,
)
SENSITIVE_VALUE = re.compile(
    r"(?i)(bearer\s+[A-Za-z0-9._~+/=-]+|(?:access[_-]?token|password|authorization|api[_-]?key)\s*[:=]\s*[^,\s]+|\b(?:\d[ -]?){13,19}\b)"
)


def sanitize(value: Any, max_length: int = 16_000) -> Any:
    if isinstance(value, dict):
        return {str(k): "[REDACTED]" if SENSITIVE_KEY.search(str(k)) else sanitize(v, max_length) for k, v in value.items()}
    if isinstance(value, list):
        return [sanitize(v, max_length) for v in value[:100]]
    if isinstance(value, str):
        return SENSITIVE_VALUE.sub("[REDACTED]", value)[:max_length]
    if value is None or isinstance(value, (bool, int, float)):
        return value
    return str(value)[:max_length]


def sanitize_report(report: Dict[str, Any], max_length: int) -> Dict[str, Any]:
    result = sanitize(report, max_length)
    return result if isinstance(result, dict) else {}


def fingerprint(report: Dict[str, Any]) -> str:
    material = "|".join(str(report.get(k, "")) for k in ("error_type", "error_message", "stack_trace"))
    return hashlib.sha256(material.encode("utf-8", "replace")).hexdigest()[:32]
