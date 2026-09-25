---
name: implement-plan
description: Implement an Approved implementation plan from docs/plans/ end to end, then complete the Definition of Done in AGENTS.md, in a repository that uses the documentation-routed workflow. Use when the owner asks to implement, build, or run a plan, e.g. "/implement-plan 0002".
---

# Implement an approved plan

The workflow's rules and the Definition of Done are in the project's `AGENTS.md`; this skill is the procedure for following them. If the repository has no `docs/plans/`, say so and suggest `/adopt-routed-workflow`.

The argument is a plan number or path. If none is given, use the plan that `docs/status.md` names as in progress or next, and confirm it with the owner.

## 1. Check the plan is ready

- Open the plan. Proceed only if its status is **Approved** (or **In progress**, when resuming) and **Open questions** is empty. Otherwise, stop and tell the owner what is missing.
- Confirm no other plan is **In progress**, using the table in `docs/plans/README.md`.
- Set the plan's status to **In progress** in the plan and in `docs/plans/README.md`, and link it from the Plans section of `docs/status.md`.

## 2. Load context

- Read everything under **Required reading**, and the related RFCs.
- The plan's **Decisions already made** are settled: follow them without asking again.
- The plan's **Non-goals** are hard boundaries. If the work seems to need one, stop and ask.
- Stop and ask under the plan's **Stop and ask if** conditions and the "When to stop and ask" list in `AGENTS.md`. Otherwise keep going without checking in.

## 3. Implement

- Follow the plan's **Steps** in order, writing the listed tests alongside the code.
- Keep changes inside the plan's scope. Record anything worth doing that is outside scope as a follow-up for the Completion record, rather than doing it.
- If reality contradicts the plan (for example, a documented rule cannot be enforced as written), stop and ask. Do not quietly change the design.

## 4. Verify

Run every command under the plan's **Verification** and fix failures. Check off each **Acceptance criteria** box only once it is proven by a test or a command you ran.

## 5. Finish

Complete every item of the **Definition of Done** in `AGENTS.md`. The plan-specific parts: update each document under the plan's **Documentation to update**, set the plan to **Done** in the plan and in `docs/plans/README.md`, and fill in its **Completion record**. Then re-run the documentation checks.

## 6. Report

Give the owner what was built, the verification results with counts, anything not verified, deviations from the plan, and follow-ups. Suggest a commit message; commit only if the owner asks.
