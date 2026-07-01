---
name: nim-error-handling
description: Design clear Nim error-handling flows; when to raise exceptions vs return `Option`/`bool`, how to enforce non-raising contracts, and where to translate or record failures. Use when reviewing failure behavior, parse errors, exception boundaries, or batch processing that needs per-item error reporting.
---

# Nim Error Handling

## Rules

### Choose the Failure Channel

- Raise when the caller must handle an outcome as failure, such as invalid data or failed I/O.
- Return `bool` for an expected miss when the caller needs success or failure. Add a `var` out-parameter when success produces a value.
- Return `Option[T]` when expected absence should be returned as a value.
- Return consumed length as `int` with `0` for no match only when a scanner must tell the caller how far to advance.
- Convert per-item failures into structured outcomes at the batch boundary. Keep intermediate steps exception-based.

### Place Boundaries

- Let failures propagate through intermediate steps.
- Catch only where the handler can recover, translate, or record the failure.
- At a batch boundary, record recoverable per-item failures. If recording itself fails, let that failure escape to the application boundary.

### Choose Exception Types

- Raise an existing specific type such as `ValueError`, `IOError`, or `OSError` when it fits.
- Separate `except` branches when handling differs. Group exception types when handling is identical.
- Catch `CatchableError` only when the boundary handles every recoverable error. Do not catch bare `Exception`.
- Add a custom exception only when callers handle it differently. Derive it from the closest existing `CatchableError` subtype.
- Derive from `Defect` only for programming bugs that callers should not recover from.

### Translate and Inspect Errors

- Translate errors only at module or subsystem boundaries. Add local context and preserve the original reason.
- If the handler only needs the message text, use `getCurrentExceptionMsg()`.
- If the handler needs exception fields, use `except X as e`.

### Cleanup and Contracts

- Use `try/finally` for cleanup.
- Use `{.raises: [].}` when a proc must not raise. Leave raising procs unannotated.

## References

- Read `references/batch_preview_boundary.md` when a batch must record per-item failures but abort if its reporting path fails.
