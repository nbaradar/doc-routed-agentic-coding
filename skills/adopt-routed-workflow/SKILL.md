---
name: adopt-routed-workflow
description: Migrate a repository to documentation-routed agentic coding — a lean always-loaded AGENTS.md with a routing table, indexed topic docs with summary/read_when headers, status and history files, RFCs, implementation plans, a Definition of Done, and doc-enforcement checks, used with the optional /project-status, /plan-unit, and /implement-plan skills. Sets up the structure from scratch in a repo without agent docs, or migrates existing documentation into it without losing information. Use when the user wants to set up or migrate a project to this workflow, restructure bloated agent docs (AGENTS.md, CLAUDE.md, PLAN.md), or reduce the context an agent loads at session start.
---

# Adopt the documentation-routed workflow

Command examples below use Claude Code syntax (`/skill-name`). In Codex, use `$skill-name` instead, including in suggested next steps.

Set up, or migrate the current repository to, this structure:

- **Contract:** `AGENTS.md` holds only the rules that always apply, plus a "Where to look" routing table. If Claude Code is used, `CLAUDE.md` contains `@AGENTS.md`.
- **Topic docs:** under `docs/`, each with `summary`/`read_when` front matter and listed in `docs/README.md`.
- **Work artifacts:** `docs/status.md` (replaced each unit), `docs/history.md` (one dated entry per unit), `docs/decisions/` (RFCs), and `docs/plans/` (implementation plans with a lifecycle).
- **Workflow:** design → plan (owner approval) → implement → Definition of Done. The rules live in the project's `AGENTS.md`, so the repository documents its own workflow for any agent or tool. The `/project-status`, `/plan-unit`, and `/implement-plan` skills are optional procedures for following those rules; they are installed once per user from this skill's repository, not copied into projects.
- **Enforcement:** `check-docs.mjs` fails when docs drift.

Resources are in this skill's directory (the one containing this file): `templates/` and `scripts/`. Read a template only when you reach the step that uses it.

## Principles

- **Nothing is lost.** Move text word for word first; condense only in a later pass the user approves. Drop only exact duplicates. Prove coverage with `scripts/coverage.py`.
- **One fact, one owner.** Every fact lives in one document; others link to it.
- **Loaded by default is expensive.** Only rules that apply to every task belong in `AGENTS.md`; history, rationale, and topic detail go to `docs/`.
- **Current state is replaced, logs grow one line at a time.** Never write "update X after every change" for a file that loads by default.
- **Human docs and agent docs are separate.** `README.md` is for people (capabilities, setup, troubleshooting); agents read it only for troubleshooting or to update it.
- **Adapt, don't impose.** Keep the project's vocabulary, commands, and existing conventions. Omit sections that don't apply (for example, an RFC process for a tiny project). Ask when unsure.

## Choose the mode

Decide before doing anything else, and tell the user which mode you chose:

- **Setup mode:** the repo has no meaningful agent or project documentation (at most a stub `README.md` or a generated `CLAUDE.md`). Create the structure from scratch: run steps 0, 1 (brief), **S**, 5, and 7. Skip the verbatim move, coverage check, and condensing.
- **Migration mode:** the repo already has agent or project documentation worth keeping (`AGENTS.md`, `CLAUDE.md`, `PLAN.md`, a substantive `README.md`, `docs/`, ADRs, editor rule files). Run steps 0–7. Nothing may be lost.

If it is borderline (for example, one short `CLAUDE.md`), use migration mode: it costs little and guarantees the existing text survives.

## 0. Preconditions

- Check `git status`. With uncommitted changes, ask before proceeding. Work on a new branch (for example, `adopt-routed-workflow`), never directly on the default branch.
- **Migration mode:** snapshot the original docs into a temporary directory (outside the repo, or in a gitignored path) before editing anything. The coverage check compares against these copies.

## 1. Assess (read-only; in setup mode, only the check commands and source layout)

- Inventory every agent-facing and project doc: `AGENTS.md`, `CLAUDE.md`, `PLAN.md`, `README.md`, `docs/**`, `.cursorrules`, `.github/copilot-instructions.md`, existing ADRs or specs, and existing `.claude/skills/` and `.agents/skills/`.
- Measure what loads by default with `python3 <skill-dir>/scripts/measure.py <files…>` (words and estimated tokens, characters ÷ 4). Include every file the agent loads automatically, plus any the user habitually references with `@`.
- Identify the project's check commands (format, lint, typecheck, test, build, integration) and its test runner and language.
- Classify each section of the existing docs as one of: **rule** (applies to every task), **topic reference** (architecture, conventions, integrations, domain model), **rationale**, **roadmap/vision**, **current status**, **history/changelog**, **human-facing** (setup, usage), or **stale** (contradicted by the code).

Report the inventory, the token baseline, and the classification summary.

## S. Setup mode: create the structure

1. Inspect the repo to prefill what you can: language, framework, package manager, the check commands (from `package.json`, `Makefile`, `pyproject.toml`, CI config, and so on), the source layout, and any existing README content.
2. Ask the user only what the repo cannot tell you, in one short round: a one-to-two sentence description of the project; any hard rules or invariants (things an agent must never do); what counts as high-risk or irreversible (for the "When to stop and ask" list); and the first thing they want to build, if known.
3. Propose the layout for this project (default in `templates/layout.md`; omit directories the project doesn't need yet, such as `docs/decisions/` or `docs/future/`) and **wait for approval**.
4. Create the files from the step 4 table and wire `check-docs.mjs` into the project's checks as step 4 describes. In `AGENTS.md`, fill the routing table with rows for the docs that exist now; there is no need to invent topic docs. Add a topic doc only when the user supplied content for it. Leave `docs/status.md` describing the real current state, and `docs/history.md` with a single dated "Adopted documentation-routed workflow" entry.
5. If the user named a first thing to build, offer to run `/plan-unit` for it after setup (if the workflow skills are installed).

Then continue with step 5 (Verify) and step 7 (Report), reporting the default-load token size of the new structure instead of before/after figures.

## 2. Migration mode: propose a layout and get approval

Propose the concrete file layout for this project (see `templates/layout.md` for the default) and the mapping of each existing section to its destination. Call out anything stale you propose to correct rather than move. **Do not edit until the user approves the layout.**

## 3. Migration mode: move content verbatim

- Write a small script (Python is fine) that copies exact line ranges from the snapshots into the new files, so the move is mechanical and reviewable. Rewrite only relative links and "§N"-style references that the move breaks.
- Collapse duplicated sections only when they are exact duplicates (or differ only in link form). Record each one.
- Where a section is replaced by a pointer (for example, `PLAN.md` sections moved to `docs/`), leave the heading with "Moved to `path`" so old references still resolve.
- Run `python3 <skill-dir>/scripts/coverage.py <snapshot files…> -- <new doc files…>` and account for every reported line: formatting only, a renamed heading, a rewritten link, a recorded duplicate, or an approved correction of stale content. Restore anything else.

## 4. Add the workflow scaffolding

Create these from `templates/`, adapting names, commands, and routing rows to the project:

| Create | From |
|---|---|
| `AGENTS.md` (rules + routing table + workflow + Definition of Done + documentation discipline) | `templates/AGENTS.md` merged with the project's moved rules |
| `CLAUDE.md` containing `@AGENTS.md` (if Claude Code is used; keep any existing content below the import) | — |
| `docs/README.md`, `docs/status.md`, `docs/history.md` | `templates/docs-README.md`, `templates/status.md`, `templates/history.md` |
| `docs/decisions/README.md` (only if the project has, or will use, RFCs/ADRs) | `templates/decisions-README.md` |
| `docs/plans/README.md`, `docs/plans/TEMPLATE.md` | `templates/plans-README.md`, `templates/plan-TEMPLATE.md` |
| `.github/pull_request_template.md` (if the project uses GitHub PRs) | `templates/pull_request_template.md` |
| `scripts/check-docs.mjs` | `scripts/check-docs.mjs` (adjust its config block) |

Do not copy the workflow skills into the project. Check whether `project-status`, `plan-unit`, and `implement-plan` are available in the current tool. Personal installation locations are `~/.claude/skills/` for Claude Code and `~/.agents/skills/` for Codex. If missing, recommend `./install.sh claude`, `./install.sh codex`, or `./install.sh both` from this skill's source repository; add `--link` to link to the clone. The project works without these skills because the rules are in `AGENTS.md`. If project copies exist in `.claude/skills/` or `.agents/skills/`, point out that duplicate names can cause ambiguity and ask before removing any copies.

Wire `check-docs.mjs` into the project's normal checks (for example, a `docs:check` package script run by the test command or CI) and list it in `AGENTS.md`'s commands and Definition of Done. Existing project work that is already specified becomes a Draft plan (with the original text kept verbatim in a "Source handoff" section), not prose in `status.md`.

## 5. Verify

- `check-docs.mjs` passes. Prove it bites: temporarily break one link, one front matter, and one plan status, confirm each fails, then restore.
- The project's own checks still pass.
- Migration mode: re-run `coverage.py` after the scaffolding step.

## 6. Migration mode: condense (optional, separate pass, with approval)

Offer this only after the verbatim migration is reviewed or committed. Condense what loads by default first (`AGENTS.md`, `status.md`, the plans index and template), then the largest on-demand files (usually a changelog written twice). Keep every rule, invariant, stop condition, and command. Prefer lists over padded tables where a formatter pads cells; use plain paths instead of Markdown links in `AGENTS.md`. Re-run the checks after.

## 7. Report

Report the mode used, the token estimates (migration: before and after for the default load, a planning session, and all docs; setup: the default load and a planning session), the new layout, anything corrected or deduplicated, what was not verified, and a suggested commit message that includes the token figures, labelled as estimates. Commit only if the user asks. If installed skills do not appear, tell the user to restart the tool they are using.
