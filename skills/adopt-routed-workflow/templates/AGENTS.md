# AGENTS.md

Working contract for coding agents on <PROJECT>, <one-line description>. Loaded on every task: it holds the rules that always apply and a map to everything else. Open mapped documents only when the task needs them.

## Where to look

Paths are relative to the repository root.

| Working on… | Read first |
|---|---|
| What to build next | `docs/status.md`, then the plan it names |
| Designing a unit of work | `docs/plans/README.md`, `docs/plans/TEMPLATE.md` |
| Implementing an approved plan | the plan and its Required reading, then Workflow below |
| <area of the codebase> | `docs/architecture/<topic>.md`, `docs/decisions/<NNNN>.md` |
| Vision, phases, open decisions | `PLAN.md` |
| Local setup or environment failures | `README.md`, Troubleshooting section only |
| Why or when something was built | `docs/history.md`, then `git log` |
| Anything else | `docs/README.md`, the full index |

`README.md` is written for people, not agents. Read it only for the troubleshooting row above, or when asked to update it or the Definition of Done requires it.

## What this system is

<Two or three sentences. What it does, and what makes mistakes expensive here.>

## <Project rules>

<Moved verbatim from the old docs: invariants, architectural boundaries, module rules, data conventions that apply to every task. Keep only rules; move rationale to topic docs.>

## Workflow

The owner and an agent design together; an agent then implements alone because the plan holds everything it needs.

1. **Design.** If the unit changes an architectural decision, write an RFC in `docs/decisions/` and get it accepted first.
2. **Plan.** Write a plan from `docs/plans/TEMPLATE.md`. It is **Approved** only when the owner explicitly approves it and it has no open questions.
3. **Implement.** Only Approved plans. Set it **In progress** and link it from `docs/status.md`. Follow its Decisions already made without re-asking, treat its Non-goals as hard boundaries, and stop under its "Stop and ask if" conditions and "When to stop and ask" below. A small change may proceed without a plan, but the Definition of Done still applies.
4. **Finish.** Complete the Definition of Done before reporting done.

Optional Claude Code and Codex skills, installed per user from the `doc-routed-agentic-coding` repository: `/project-status` (short status report), `/plan-unit` (design, plan, approval, resume a Draft), `/implement-plan` (implement and finish). In Codex, invoke these as `$project-status`, `$plan-unit`, and `$implement-plan`. The rules above apply with or without them.

### Definition of Done

Report any item not completed, and why; never skip one silently.

- [ ] Every plan acceptance criterion is met and checked off.
- [ ] <the project's check commands> pass, including `node scripts/check-docs.mjs`.
- [ ] Every document in the plan's "Documentation to update" is updated.
- [ ] `docs/status.md` is replaced (not appended) with the new state, verified counts, and next plan.
- [ ] `docs/history.md` has one new dated entry.
- [ ] `README.md` is updated if a capability, setup step, or known problem changed.
- [ ] The plan is **Done**, with a Completion record: date, verified counts, deviations, follow-ups.
- [ ] Anything unverified (e.g. a UI flow not tried in a browser) is stated in the Completion record and the final report.

### Documentation discipline

Every fact has one owning document; update the owner and link to it instead of copying.

- **Design changes:** update the owning topic doc or RFC. Accepted RFCs are not rewritten; a changed decision gets a new RFC that supersedes the old one.
- **This file:** change only when a rule or the routing table changes.
- **New documents:** start with `summary` and `read_when` front matter, add an entry to `docs/README.md` (plans go in `docs/plans/README.md`), and add a routing row above if it is a primary entry point. `check-docs.mjs` enforces front matter, indexes, links, `AGENTS.md` paths, and plan statuses.
- Describe completed behavior only; mark planned or unverified behavior clearly. Commit messages carry the detail.

## Commands

```bash
<project commands, one line each with a short comment>
node scripts/check-docs.mjs   # documentation checks
```

## When to stop and ask

- The task appears to require breaking a rule above.
- <Project-specific irreversible or high-risk actions.>
- Behavior of an external system contradicts these documents.

A wrong guess can be expensive; an unanswered question costs a few minutes.
