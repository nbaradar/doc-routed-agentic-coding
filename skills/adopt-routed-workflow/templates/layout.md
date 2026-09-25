# Default layout

Adapt to the project; omit what it doesn't need.

```text
CLAUDE.md                 "@AGENTS.md" (Claude Code loads the contract automatically)
AGENTS.md                 always-loaded rules + "Where to look" routing table + workflow + Definition of Done
PLAN.md                   vision, non-goals, phases, open decisions (moved sections leave "Moved to" pointers)
README.md                 for humans: capabilities table, how it's built, setup, troubleshooting
docs/
  README.md               index: every doc and its read_when
  status.md               current state, agreed priority, active/next plan (replaced, never appended)
  history.md              one dated entry per completed unit, oldest first
  architecture/           one file per topic: overview, data model, modules, security, testing, UI…
  decisions/              RFCs / ADRs + README index and conventions
  plans/                  NNNN-title.md plans + TEMPLATE.md + README index with statuses
  future/                 deliberately deferred work and its rules
.claude/skills/
  project-status/         short status report
  plan-unit/              design → plan → owner approval
  implement-plan/         implement an approved plan → Definition of Done
.github/pull_request_template.md
scripts/check-docs.mjs    documentation enforcement
```

Mapping guide for existing content:

| Existing content | Destination |
|---|---|
| Rules that apply to every task (invariants, boundaries, style, commands, secrets, when to stop) | `AGENTS.md` |
| Topic reference (architecture, data model, integrations, conventions) | `docs/architecture/*.md` or `docs/<topic>.md` |
| Rationale behind rules | the topic doc that owns the concept |
| Vision, phases, non-goals, open decisions | `PLAN.md` |
| Current state and next steps | `docs/status.md` |
| Dated completion logs, changelogs | `docs/history.md` |
| Specified-but-unbuilt work | a Draft plan in `docs/plans/` |
| Setup, usage, troubleshooting | `README.md` |
| Deferred features, multi-user or scaling plans | `docs/future/` |
