---
name: nim-vuln-discovery
description: Systematic vulnerability discovery in Nim codebases. Use when auditing Nim source for security bugs, analyzing attack surfaces, triaging findings, or producing evidence-backed vulnerability reports with confidence scoring.
---

# Nim Vulnerability Discovery

This baseline skill provides a deterministic workflow for finding security
vulnerabilities in Nim source code. It records scope, attack surfaces,
hypotheses, evidence, and confidence scores.

## Workflow Stages

Execute these stages in order.

### 1. Scope Definition

Identify target modules, imports, exported symbols, conditional compilation,
async annotations, data flow, and trust boundaries.

Output: `Module | Entry Point | Data Flow | Trust Boundary Crossings`.

### 2. Attack Surface Enumeration

Classify trust-boundary crossings:

| Surface | Examples |
|---|---|
| `parse` | `parseInt`, `parseEnum`, `parseUri`, `split`, regex, custom parsers |
| `alloc` | `new`, `newSeq`, `newString`, `setLen`, accumulating `add` |
| `recv` | network reads and length arguments |
| `index` | indexing, slicing, substrings |
| `cast` | `cast`, `addr`, pointer arithmetic |
| `ffi` | `importc`, `exportc`, `{.emit.}` |
| `async` | `Future`, cancellation, reentrancy |
| `int` | overflow, saturation, conversions |

Output: `# | File:Line | Surface Type | Input | Validation | Failure Mode`.

### 3. Vulnerability Hypothesis Generation

For each surface, generate up to three memory, logic, or resource hypotheses.
Each hypothesis must name input shape, expected behavior, actual behavior, and
the code path that would be triggered.

### 4. Evidence Collection

Collect:

- static trace through calls and branches
- a minimal Nim reproducer when practical
- sanitizer confirmation when applicable

Suggested reproducer builds:

```bash
nim c --panics:on --mm:arc -r repro.nim
nim c -d:danger -r repro.nim
```

Suggested sanitizer build:

```bash
nim c --cc:clang -g -d:noSignalHandler -d:useMalloc \
  --passC:"-fsanitize=address,undefined" \
  --passL:"-fsanitize=address,undefined" \
  -r repro.nim
```

### 5. Triage and Classification

| Classification | Criteria |
|---|---|
| `CONFIRMED` | Reproducer crashes or sanitizer fires; root cause identified in code |
| `LIKELY` | Static trace shows missing validation but no crash reproduced yet |
| `UNLIKELY` | Theoretical path exists but practical constraints make exploitation infeasible |
| `FALSE_POSITIVE` | Validation exists that was missed in initial analysis |
| `BENIGN` | Crash occurs but no security impact |

### 6. Confidence Scoring

Assign:

```text
Confidence = EvidenceFactor * ExploitabilityFactor * ImpactFactor
```

Evidence:

- `1.0` sanitizer output and reproducer
- `0.7` static trace and dynamic test
- `0.4` static trace only
- `0.1` speculative

Exploitability:

- `1.0` attacker fully controls input
- `0.7` partial control
- `0.4` specific timing or concurrency
- `0.1` unrealistic conditions

Impact:

- `1.0` RCE or memory corruption
- `0.8` denial of service
- `0.6` information disclosure
- `0.4` logic bypass
- `0.2` minor spec violation

## False Positive Reduction

Before reporting, check validation, bounds checks, caught exceptions, compiler
guards, allocation limits, type constraints, and GC rooting.

## Required Evidence

Every finding needs file and line numbers, triggering input, expected vs actual
behavior, static trace, classification, confidence, exploitability, and a
reproducer for confirmed findings.

## Communication Rules

- Never report "potential" without classification and confidence.
- Never report a finding based only on the presence of risky APIs.
- Prefer "no finding" over low-confidence speculation.
