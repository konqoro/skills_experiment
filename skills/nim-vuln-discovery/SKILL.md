---
name: nim-vuln-discovery
description: Find security vulnerabilities in Nim codebases with deterministic triage, bounded confirmation attempts, exploitability analysis, and evidence-backed reports. Use when auditing Nim source, reviewing parser/I/O/FFI/async/ownership attack surfaces, validating suspected bugs, or reducing false positives in Nim security findings.
---

# Nim Vulnerability Discovery

Use this skill to audit Nim code for security bugs. Treat every finding as a
hypothesis until a static trace and, where practical, a small reproducer support
it. Prefer fewer, well-evidenced findings over broad speculation.

## Scope

Audit code that processes untrusted input, crosses a privilege or trust
boundary, or manages resources manually.

In scope:

- parsing, decoding, deserialization, config/file/network input
- indexing, slicing, integer arithmetic, size conversions
- allocation and accumulation of `string`, `seq`, buffers, tables, queues
- async I/O, cancellation, timeouts, shared state, callbacks
- C FFI, `ptr`, `pointer`, `cstring`, `cast`, `{.emit.}`, manual alloc/free
- custom `=destroy`, `=copy`, `=dup`, `=sink`, `=wasMoved`
- exception boundaries where `Defect` may escape instead of `CatchableError`

Out of scope unless the user asks:

- style-only refactors
- theoretical issues with no reachable attacker-controlled input
- low-impact spec disagreements with no security effect

## Workflow

Run the stages in order. Keep notes short and structured.

### 1. Map The Boundary

Identify:

- target files and exported entry points
- untrusted inputs and who controls them
- data flow from input to parser/state/I/O/resource operation
- build modes or `when defined(...)` branches that affect safety
- async, thread, callback, or FFI boundaries

Output one table:

`Entry | Input Control | Path | Sensitive Operation | Existing Guard`

### 2. Enumerate Nim-Specific Risk Sites

Search with `rg` before reading whole files.

High-signal patterns:

```text
parseInt|parseUInt|parseBiggestInt|parseSaturatedNatural|parseHexInt|parseEnum
split|substr|find|skip|parseUntil|parseWhile|parseUri|parseJson|parseXml
\[[^]]+\]|\.\.|\.\.<|setLen|newString|newSeq|newStringOfCap|add\(
recv|recvLine|recvLineInto|read|readLine|accept|send|Future|async|await
cast\[|addr |ptr |pointer|cstring|alloc|dealloc|copyMem|zeroMem|importc|emit
=destroy|=copy|=dup|=sink|=wasMoved|doAssert|assert|raises:
```

For each candidate site, record only what matters:

`File:Line | Risk | Reached From | Guard | Candidate Failure`

### 3. Generate Bounded Hypotheses

Create at most two hypotheses per risk site. Each hypothesis must include:

- exact input shape or state transition
- attacker control level
- expected behavior
- suspected actual behavior
- shortest code path to the risky operation

Discard hypotheses that cannot name a reachable input.

### 4. Confirm Cheaply

Use a bounded confirmation ladder. Stop when the classification is clear.

1. **Static trace, 5-10 minutes**
   - Trace input to operation.
   - Check all guards, catches, limits, and `when` branches.
   - For parsers, verify consumed-length semantics and whether trailing input is checked.
   - For exceptions, distinguish `CatchableError` from `Defect`; bare `except:` and
     `except CatchableError` do not catch `IndexDefect`, `OverflowDefect`,
     `AssertionDefect`, etc.

2. **Minimal reproducer, 10-20 minutes**
   - Write the smallest `.nim` program that calls the reachable code path.
   - Prefer direct unit-style calls before integration tests.
   - Use `doAssert`; do not rely on `assert` because it is removed in `-d:danger`.
   - Record command, output, exit code, and stack trace.

3. **Mode check, 5-10 minutes**
   - Run the reproducer in the relevant modes:

     ```bash
     nim c -r repro.nim
     nim c --panics:on --mm:arc -r repro.nim
     nim c -d:release --lineTrace:on -r repro.nim
     nim c -d:danger --lineTrace:on -r repro.nim
     ```

   - Skip modes that are irrelevant to the project, but say why.

4. **Sanitizer check, only for unsafe memory/FFI/manual allocation**

   ```bash
   nim c --cc:clang -g -d:noSignalHandler -d:useMalloc \
     --passC:"-fsanitize=address,undefined -fno-omit-frame-pointer" \
     --passL:"-fsanitize=address,undefined -fno-omit-frame-pointer" \
     -r repro.nim
   ```

5. **Fuzz or integration test, only when direct reproduction is insufficient**
   - Use when the bug depends on many parser states, byte sequences, timing, or
     async/network behavior.
   - Keep harness scope narrow. Save crashing input, seed corpus, command, and log.

If a confirmation step exceeds its time box, downgrade to `LIKELY` or `LOW`
with the exact missing evidence. Do not keep exploring indefinitely.

## Triage Rules

Classify each candidate:

| Class | Use When |
|---|---|
| `CONFIRMED` | A reproducer, sanitizer report, fuzz artifact, or integration test demonstrates the failure and the root cause is traced. |
| `LIKELY` | Complete static trace shows attacker-controlled input reaches a missing guard, but dynamic confirmation was not completed. |
| `LOW` | Reachability or impact depends on uncommon configuration, race timing, deployment assumptions, or unclear caller behavior. |
| `FALSE_POSITIVE` | A guard, type constraint, catch boundary, limit, or unreachable path prevents the issue. |
| `NON_SECURITY` | Behavior is a bug or spec mismatch but lacks credible confidentiality, integrity, availability, or privilege impact. |

Never mark a finding `CONFIRMED` from source reasoning alone.

## Confidence Scoring

Use coarse scores. Do not multiply pseudo-probabilities.

| Score | Meaning |
|---:|---|
| 0.95 | Confirmed with reproducer or sanitizer/fuzzer artifact and root-cause trace. |
| 0.80 | Confirmed by deterministic integration test; exploitability constraints are understood. |
| 0.60 | Likely: complete static trace, clear attacker control, no dynamic confirmation yet. |
| 0.40 | Plausible: partial trace or deployment-dependent exploitability. |
| 0.20 | Weak: speculative, unclear reachability, or low impact. |
| 0.00 | False positive or non-security behavior. |

If two adjacent scores seem possible, choose the lower score and state the
missing evidence.

## False-Positive Reduction

Before reporting, check:

- Is the input attacker-controlled at the vulnerable point?
- Is the candidate path reachable under the project build flags?
- Is there a size limit, timeout, auth check, enum/range type, or prior parser guard?
- Does a parser return consumed length, and does the caller verify full consumption?
- Does the code catch the actual exception type, or only `CatchableError`?
- In `-d:danger`, are overflow/assert checks removed in a way that changes the result?
- For async code, can cancellation/reentrancy/shared state make the path real?
- For FFI, are pointer lifetimes, nullability, struct layout, calling convention,
  and string ownership correct?
- For ownership hooks, are move-after-destroy, self-copy, zero-length allocation,
  and destroy-after-move safe?

If a guard blocks the path, report `FALSE_POSITIVE` with the blocking line.

## Required Evidence

Every reported finding must include:

- title and classification
- affected file and line
- attacker-controlled input or state
- static trace from entry point to failure
- expected vs actual behavior
- root cause
- exploitability and impact
- confidence score
- reproduction command or reason dynamic reproduction was not completed
- remediation direction

For `CONFIRMED`, also include:

- exact input, fixture, or sequence
- command lines
- observed output, crash, stack trace, sanitizer report, or fuzz artifact
- why the result is security-relevant

## Exploitability Analysis

Answer these concretely:

- Who controls the input?
- What preconditions are required?
- Is authentication needed?
- Is the impact crash, hang, memory exhaustion, corruption, info leak, bypass,
  injection, or privilege boundary crossing?
- Is exploitation single-request/single-file, repeated, timing-dependent, or
  deployment-dependent?
- What existing limits reduce impact?

Avoid "could be exploited" unless these questions are answered.

## Report Format

```markdown
### Finding F-XXX: Title

- Classification: CONFIRMED | LIKELY | LOW | FALSE_POSITIVE | NON_SECURITY
- Confidence: 0.XX
- Type: crash | resource exhaustion | memory safety | logic bypass | injection | ...
- Affected code: `path/file.nim:line`
- Input/control: exact input or state transition
- Static trace: entry -> function -> branch -> operation -> failure
- Evidence: command/output or reason confirmation was not completed
- Expected behavior:
- Actual behavior:
- Exploitability:
- Remediation:
```

## Execution Rules

- Start broad, then narrow quickly. Do not fully analyze every low-signal site.
- Batch similar candidates and confirm the strongest one first.
- Prefer direct reproducers over large harnesses.
- Prefer `CONFIRMED` with one saved input over many unvalidated claims.
- Do not invent line numbers, commands, or outputs.
- Do not add target-specific rules to this skill; keep project-specific lessons in
  the project report, not here.
