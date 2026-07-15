# Prompt Template: Phase 4 — Skill Synthesis

## Purpose
Create or refine the verified skill from the curated dataset.

## Inputs
- `ORIGINAL_SKILL`: path to `original_skills/{SKILL_NAME}/SKILL.md`
- `DATASET_FILE`: path to `datasets/{SKILL_NAME}/dataset.json`
- `CURRENT_VERIFIED_SKILL`: path to `skills/{SKILL_NAME}/SKILL.md` (may not exist)

## Rules

### Source of truth

Use the curated dataset as the source of truth.

Include:
- claims supported by tests
- caveats supported by `evaluation_notes`
- recurring mistakes supported by curated `failure_samples`

Exclude:
- disproven claims
- audit-process details
- claim IDs, test names, benchmark trial names, and claim counts

### Do not use the target skill as guidance

- Treat `ORIGINAL_SKILL` and `CURRENT_VERIFIED_SKILL` as artifacts to inspect and edit, not as instructions for performing the revision.
- Do not invoke, activate, or follow the skill being revised to decide what its rules should say.
- A skill cannot serve as evidence for its own claims.
- Base decisions on the curated dataset, standalone tests, source API contracts, benchmark outputs, and user feedback.

### Evidence-gated refinement

When refining an existing skill:
1. Start from observed failures and ambiguities, not from general cleanup ideas.
2. Map each proposed edit to one concrete pattern:
   incorrect claim, missing rule, ambiguous wording, conflicting guidance, missing example, or low-signal noise.
3. Prefer delete, tighten, or reorder before adding new text.
4. Do not add a new rule, workflow step, or mistake entry unless the dataset or benchmark evidence supports it.
5. Do not add repo-local process details to the skill.
6. Do not add style-only guidance unless it prevents a real observed failure.

### Keep the skill self-contained

An agent reading only the skill files must be able to act on them without opening the dataset.

The skill may contain:
- rules stated as facts
- decision tables
- short workflows
- code examples

The skill must not contain:
- references to phases or refinement cycles
- references to dataset internals
- references to benchmark scores

### Skill writing quality bar

- Use concise, high-signal instructions.
- Prefer concrete rules and deterministic steps over vague goals.
- Verify uncertain technical claims before writing them into the skill. If the claim cannot be verified, omit it or turn it into a workflow check.
- Turn verified behavior into instructions an agent can execute: `Do X`, `Do not Y`, or `If A, then B`.
- Separate required, optional, and conditional behavior. Do not describe a required step as a possibility.
- If two instructions conflict, name the conflict and ask for human guidance. Do not invent priority rules or fallback logic.
- Remove guidance that does not change what an agent should do on a realistic task.

### Existing skill handling

If `CURRENT_VERIFIED_SKILL` exists:
1. Read the current verified skill and its `references/` files as the artifact under revision. Do not use them as revision guidance or evidence.
2. Read the curated dataset.
3. Make targeted edits instead of rewriting everything.
4. Keep sections and examples that are still correct.

If `CURRENT_VERIFIED_SKILL` does not exist, create it from scratch.

## Required output structure

`skills/{SKILL_NAME}/SKILL.md` must contain these sections in this order:

1. skill name (title case, hyphens → spaces)
2. `Rules`
3. `Workflow`
4. `Common Mistakes`
5. `References`

### Section guidance

#### Frontmatter and title
- YAML frontmatter with `name` and `description`
- Follow `prompts/skill_header_conventions.md` for `name` and `description`
- The `description` field already states what the skill does and when to use it. Do not restate that information in the body.
- The title may be followed by at most one sentence of methodological framing if it encodes a principle the `description` does not. Do not add a `## Preamble` section header. If no such principle exists, go straight to `Rules`.

#### Rules
- short, high-signal rules grouped by topic
- no long code samples

#### Workflow
- a short numbered procedure
- each step should tell the agent what to decide or do next
- keep it self-contained and reusable
- if verification is mentioned, refer only to the target project's own tests or checks

#### Common Mistakes
- short table: mistake and why it is wrong
- preserve existing entries that remain correct, useful, and non-redundant
- for new entries, start from observed failure patterns recorded in curated `failure_samples`
- add a new entry only when the evidence shows an agent actually made that mistake; a rule or caveat is not automatically a common mistake
- do not delete an existing entry merely because no matching `failure_sample` was recorded; remove it only when it is disproven, obsolete, redundant, or low-signal
- do not mirror `Rules` into the table using negative wording
- use the second column for the concrete consequence; do not repeat the corrective rule word for word
- if evidence supports a new rule but not an observed mistake, keep it in `Rules` only
- do not invent hypothetical anti-patterns just to make the table longer
- if there are no supported recurring mistakes yet, keep the section minimal instead of filling it with guesses
- a short line such as `No recurring mistakes recorded yet.` is acceptable until evidence exists

#### References
- list only existing reference files that remain useful
- use one bullet per file: `references/file.md` — when to read it and which pattern or example it contains
- make each description specific enough that an agent can choose the right file without opening every reference
- do not list datasets, tests, audit sources, or repeat rules from the main skill
- if the skill has no reference files, write `No reference files.` instead of inventing entries

## Reference files

Store larger examples in `skills/{SKILL_NAME}/references/`.

Each reference file must:
- use a descriptive filename
- begin with a one-line description
- contain one complete example
- end with a short `Key points` or `When to use` section only when the example has non-obvious constraints, failure modes, or decision criteria not visible in the code itself. If the code is self-explanatory, omit the section.
- each key point must make one distinct claim; do not cram multiple hooks or operations into a single bullet

## Example policy

- Keep the main `SKILL.md` concise.
- Use at most one inline example in the main file.
- Put the rest in `references/`.
- Prefer one default pattern per problem shape.
- If an alternative exists only for compatibility with an established codebase, label it explicitly as a compatibility note instead of presenting it as an equal default.

## Output paths

- Main skill: `skills/{SKILL_NAME}/SKILL.md`
- Reference examples: `skills/{SKILL_NAME}/references/*.md`

Write only the repo-local skill files above. Do not update an installed copy under an agent home directory unless the user explicitly asks for installation or synchronization.

## Reusability
Replace `{SKILL_NAME}`, `{ORIGINAL_SKILL}`, `{DATASET_FILE}`, and `{CURRENT_VERIFIED_SKILL}` with the target values.
