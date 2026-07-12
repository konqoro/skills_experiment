---
name: nim-defect-analysis
description: Find reliability and security defects in Nim code. Use when reviewing Nim source for bugs, auditing parsers or protocol handlers for crashes, checking FFI or ownership code for memory safety, or reducing false positives in code review findings.
---

# Nim Defect Analysis

Use this skill to find real bugs in Nim code. Focus on finding and confirming
defects, not on elaborate triage mechanics. A finding is real when you can
demonstrate it; until then it is a hypothesis.

# Rules

## Look Broadly

Review the code for correctness and reliability defects. Do not restrict
attention to a fixed checklist of patterns or API names. Common bug sites
include:

- parsing, decoding, deserialization, and any external input handling
- indexing, slicing, integer arithmetic, and size conversions
- allocation and accumulation in `string`, `seq`, buffers, tables, and queues
- async I/O, cancellation, shared state, and callbacks
- C FFI, `ptr`, `cstring`, `cast`, `{.emit.}`, manual allocation
- custom `=destroy`, `=copy`, `=dup`, `=sink`, and `=wasMoved`
- exception boundaries where `Defect` may escape `CatchableError` handlers
- logic errors, off-by-one, wrong conditions, missing cases

This list is illustrative, not exhaustive. If something looks wrong, investigate
it regardless of whether it matches a known pattern.

## Search Efficiently

Use `rg` to locate risky operations quickly — parsing functions, allocation,
pointer operations, casts, FFI imports, ownership hooks. But also read the code
to understand its logic. Many bugs are logic errors that no pattern search will
find.

## Confirm Before Reporting

A finding is `CONFIRMED` when a reproducer, sanitizer, or test demonstrates the
failure. Until then it is `UNCONFIRMED`. If a guard blocks the path, it is
`FALSE_POSITIVE`.

Do not assign numbers. Do not invent probability or confidence scores. State
what you found and what evidence you have.

## Build Minimal Reproducers

For each candidate defect, write the smallest reproducer that triggers it.
Prefer direct calls over integration tests. Use `doAssert` for assertions, not
`assert` — `assert` is compiled out under `-d:danger`.

Default build:

```bash
nim c -r repro.nim
```

Additional modes when the bug depends on them:

```bash
nim c --panics:on -r repro.nim       # Defect termination behavior
nim c -d:danger -r repro.nim          # Overflow and assertion behavior
nim c --mm:arc -r repro.nim           # Ownership and hook behavior
```

Sanitizers for unsafe memory, FFI, or manual allocation:

```bash
nim c --cc:clang -g -d:noSignalHandler -d:useMalloc \
  --passC:"-fsanitize=address,undefined -fno-omit-frame-pointer" \
  --passL:"-fsanitize=address,undefined -fno-omit-frame-pointer" \
  -r repro.nim
```

`useMalloc` exposes Nim allocations to ASan. `noSignalHandler` lets ASan report
signal-based crashes.

## Check For Guards

Before reporting, verify whether the path is actually reachable:

- Does external input reach the defect site?
- Is there a bounds check, limit, range type, or parser guard?
- Does a `catch` boundary catch the exception? `Defect` subclasses
  (`IndexDefect`, `OverflowDefect`, `AssertionDefect`) are not caught by
  `except CatchableError`.
- Does `-d:danger` change the behavior?
- Are there `when defined(...)` branches that affect the path?
- For parser defects: check whether functions that return a consumed length
  leave trailing input unvalidated.
- For FFI defects: check pointer lifetime, nullability, struct layout, calling
  convention, and string ownership.
- For ownership-hook defects: check move-after-destroy, self-copy, zero-length
  allocation, and destroy-after-move.

If a guard blocks the path, report `FALSE_POSITIVE` with the blocking line.

## Report Concisely

Each finding needs:

- file and line
- what is wrong
- how input reaches it
- expected vs actual behavior
- evidence: reproducer command and output for `CONFIRMED`, static trace for
  `UNCONFIRMED`, blocking guard for `FALSE_POSITIVE`
- remediation direction

Keep the report short. Prefer a few well-evidenced findings over many
speculative ones.

# Workflow

1. **Read the code.** Understand what it does, where input enters, and where
   sensitive operations happen. Look for anything that could go wrong.
2. **Trace candidate defects.** For each suspicious site, trace the path from
   input to the operation. Check for guards along the way.
3. **Write a minimal reproducer.** Confirm the bug with the smallest possible
   input. If you cannot reproduce it, state what is missing.
4. **Report.** List confirmed findings with evidence, unconfirmed findings with
   their static traces, and false positives with the blocking guard.

# Common Mistakes

| Mistake | Why it is wrong |
|---|---|
| Marking a source-only claim `CONFIRMED` | Confirmation requires executable evidence. |
| Reporting a risky API call without a reachable path | API presence is not a defect. |
| Ignoring `Defect` vs `CatchableError` | `IndexDefect`, `OverflowDefect`, and `AssertionDefect` escape ordinary handlers. |
| Treating `assert` as a reliable guard | `assert` is compiled out in `-d:danger`; use `doAssert` in tests. |
| Assigning numerical confidence scores | Numbers add false precision without improving the analysis. |

# References

No reference files.
