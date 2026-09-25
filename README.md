# Documentation-Routed Agentic Coding

A Claude Code skill that sets up — or migrates a repository to — a documentation structure and workflow built for coding agents:

- **A small always-loaded contract.** `AGENTS.md` holds only the rules that apply to every task, plus a routing table that tells the agent which document to open for which kind of work.
- **Topic docs loaded on demand.** Each doc under `docs/` starts with a `summary` and `read_when` header, so the agent can decide what to read.
- **A design → plan → implement → finish workflow.** You and the agent design a unit of work together; an agent then implements it on its own and finishes with a Definition of Done.
- **Checks that keep the docs honest.** A dependency-free script fails when indexes, links, headers, or plan statuses drift.

On the project it was built for, this cut the context loaded at session start from roughly 26,500 to 6,300 tokens (estimates).

📖 **Full write-up:** [Documentation-Routed Agentic Coding](https://nbaradar.github.io/the-latent-space/Notes-+-Research/AI-+-ML/Agentic-Coding/Workflows/Documentation-Routed-Agentic-Coding): the reasoning, the structure, lessons learned, and results. A companion page, [Testing Documentation-Routed Agentic Coding](https://nbaradar.github.io/the-latent-space/Notes-+-Research/AI-+-ML/Agentic-Coding/Workflows/Testing-Documentation-Routed-Agentic-Coding), covers how to check whether it actually helps your agents.

## Install

Requires [Claude Code](https://docs.claude.com/en/docs/claude-code/overview). The doc checker needs Node.js; the migration-coverage and token-measuring scripts need Python 3.

```bash
git clone https://github.com/nbaradar/doc-routed-agentic-coding.git doc-routed-agentic-coding
cd doc-routed-agentic-coding
./install.sh          # copies the skill to ~/.claude/skills/
# or
./install.sh --link   # symlinks it instead, so `git pull` keeps it updated
```

Restart Claude Code so the skill is picked up.

## Use

Open Claude Code in the repository you want to set up and run:

```text
/adopt-routed-workflow
```

The skill first chooses a mode and tells you which:

| Mode | When | What happens |
|---|---|---|
| **Setup** | The repo has no meaningful docs | Inspects the repo, asks a few questions, proposes a layout, then creates the structure |
| **Migration** | The repo has existing agent or project docs | Snapshots them, proposes where each section goes, moves text word for word, proves nothing was lost, then adds the workflow |

It works on a new branch, waits for your approval of the layout before editing, and ends with a report: token estimates, what changed, and what it couldn't verify. It never commits unless you ask.

### After setup: the day-to-day loop

The skill installs three project skills into `.claude/skills/`:

1. **`/project-status`**: a short report of what was last built, what's in progress, and what needs you.
2. **`/plan-unit`**: design the next piece of work together; it writes a plan and asks you to **Approve**, **Revise**, or **Keep as Draft**.
3. **`/implement-plan <n>`**: ideally in a fresh session, the agent implements the approved plan on its own and runs the Definition of Done.

## What's in this repo

```text
install.sh                          installs the skill for your user
skills/adopt-routed-workflow/
  SKILL.md                          the skill's instructions
  templates/                        AGENTS.md skeleton, doc templates, plan template,
                                    PR template, and the three project skills
  scripts/
    check-docs.mjs                  dependency-free documentation checks (settings at the top)
    coverage.py                     proves a migration lost nothing
    measure.py                      estimates tokens (characters ÷ 4)
```

Everything under `skills/adopt-routed-workflow/` is self-contained. You can also use the pieces on their own; for example, copy `scripts/check-docs.mjs` into any repo that follows the same doc conventions.

## Status

New and not yet widely tested. Feedback and results are welcome.

## License

[MIT](LICENSE)
