# Documentation-Routed Agentic Coding

A shared set of Claude Code and Codex skills that sets up — or migrates a repository to — a documentation structure and workflow built for coding agents:

- **A small always-loaded contract.** `AGENTS.md` holds only the rules that apply to every task, plus a routing table that tells the agent which document to open for which kind of work.
- **Topic docs loaded on demand.** Each doc under `docs/` starts with a `summary` and `read_when` header, so the agent can decide what to read.
- **A design → plan → implement → finish workflow.** You and the agent design a unit of work together; an agent then implements it on its own and finishes with a Definition of Done.
- **Checks that keep the docs honest.** A dependency-free script fails when indexes, links, headers, or plan statuses drift.

On the project it was built for, this cut the context loaded at session start from roughly 26,500 to 6,300 tokens (estimates).

📖 **Full write-up:** [Documentation-Routed Agentic Coding](https://nbaradar.github.io/the-latent-space/Notes-+-Research/AI-+-ML/Agentic-Coding/Workflows/Documentation-Routed-Agentic-Coding): the reasoning, the structure, lessons learned, and results. A companion page, [Testing Documentation-Routed Agentic Coding](https://nbaradar.github.io/the-latent-space/Notes-+-Research/AI-+-ML/Agentic-Coding/Workflows/Testing-Documentation-Routed-Agentic-Coding), covers how to check whether it actually helps your agents.

## Install

Requires Claude Code or Codex and Bash. Node.js is needed for the documentation checker; Python 3 is needed for migration coverage and token measurement. Neither is required to install the skills.

```bash
git clone https://github.com/nbaradar/doc-routed-agentic-coding.git
cd doc-routed-agentic-coding
./install.sh both --link  # development setup: both tools read skills from this clone
```

Choose one tool or both, and whether to copy or link:

```bash
./install.sh claude       # copy to ~/.claude/skills/
./install.sh codex        # copy to ~/.agents/skills/
./install.sh both         # copy to both locations
./install.sh codex --link # link instead of copying (also works with claude or both)
./install.sh              # ask which tool; no default selection
./install.sh --link       # ask which tool, then create links
./install.sh --help
```

The prompt accepts `1` (Claude Code), `2` (Codex), or `3` (both); `q` cancels. Without interactive input, a tool argument is required. Skills are installed once for your user and can be used across repositories.

| Tool | Personal destination | Optional installer override |
|---|---|---|
| Claude Code | `~/.claude/skills/` | `CLAUDE_SKILLS_DIR` |
| Codex | `~/.agents/skills/` | `CODEX_SKILLS_DIR` |

These environment variables only change where this script installs files; they do not configure skill discovery in either tool. For example, `CODEX_SKILLS_DIR=/custom/location ./install.sh codex` installs to a custom location that must already be discoverable by Codex.

### Copies, links, and updates

Copy mode creates independent installed directories. Updating your clone does not update those copies. To refresh a copy, remove only the installed skill directory you intend to replace, then rerun the installer. Existing destinations are never overwritten; conflicts are reported and produce a nonzero exit status. When installing for both tools, conflicts in one destination do not prevent processing the other.

With `--link`, installed entries point back to the corresponding directories in your clone:

```text
~/.claude/skills/plan-unit/ -> /path/to/clone/skills/plan-unit/
~/.agents/skills/plan-unit/ -> /path/to/clone/skills/plan-unit/
```

Edits and `git pull` change the files both tools read. Keep the clone in place: moving or deleting it breaks the links. Editing through a link edits the source; removing the link itself leaves the source intact. Reinstalling an already-correct link succeeds without replacing it. Restart the tool if changes are not reflected in a current session.

### Windows

Run `install.sh` in Git Bash or WSL, not directly in PowerShell. You can also use `bash ./install.sh both --link` in a Bash shell. Use the home directory of the environment where your tool runs: WSL's home is normally different from your Windows home.

For real Windows symlinks in Git Bash, enable Windows Developer Mode or use an account with symlink privileges, then run:

```bash
MSYS=winsymlinks:nativestrict ./install.sh both --link
```

The installer reports failure if a real link cannot be created. Copy mode avoids the symlink requirement.

## Use

Open your chosen tool in the repository you want to set up, then invoke the adoption skill:

| Task | Claude Code | Codex |
|---|---|---|
| Set up or migrate | `/adopt-routed-workflow` | `$adopt-routed-workflow` |
| Check status | `/project-status` | `$project-status` |
| Design or resume a plan | `/plan-unit 0001` | `$plan-unit 0001` |
| Implement an approved plan | `/implement-plan 0001` | `$implement-plan 0001` |

Start a new Claude Code session after installation. In Codex, use `/skills` or type `$` to select a skill; restart if it does not appear. Codex's user skill location and symlink support are documented in the [official skill guide](https://learn.chatgpt.com/docs/build-skills).

The skill first chooses a mode and tells you which:

| Mode | When | What happens |
|---|---|---|
| **Setup** | The repo has no meaningful docs | Inspects the repo, asks a few questions, proposes a layout, then creates the structure |
| **Migration** | The repo has existing agent or project docs | Snapshots them, proposes where each section goes, moves text word for word, proves nothing was lost, then adds the workflow |

It works on a new branch, waits for your approval of the layout before editing, and ends with a report: token estimates, what changed, and what it couldn't verify. It never commits unless you ask.

### After setup: the day-to-day loop

The workflow's rules live in the project's `AGENTS.md`, so the repository documents its own workflow for any agent or tool. Three skills make following those rules quick (examples below use Claude syntax; use `$` instead of `/` in Codex):

1. **`/project-status`**: a short report of what was last built, what's in progress, and what needs you.
2. **`/plan-unit`**: design the next piece of work together; it writes a plan and asks you to **Approve**, **Revise**, or **Keep as Draft**. `/plan-unit NNNN` resumes a Draft.
3. **`/implement-plan <n>`**: ideally in a fresh session, the agent implements the approved plan on its own and runs the Definition of Done.

## What's in this repo

```text
install.sh                          installs for claude, codex, or both (copy, or --link)
skills/
  adopt-routed-workflow/            sets up or migrates a repository
    SKILL.md                        the skill's instructions
    templates/                      AGENTS.md skeleton, doc templates, plan template, PR template
    scripts/
      check-docs.mjs                dependency-free documentation checks (settings at the top)
      coverage.py                   proves a migration lost nothing
      measure.py                    estimates tokens (characters ÷ 4)
  project-status/                   short status report
  plan-unit/                        design → plan → approval, or resume a Draft
  implement-plan/                   implement an approved plan → Definition of Done
```

Each skill is self-contained and generic: project-specific details, such as check commands and which changes need an RFC, come from the project's `AGENTS.md`. You can also use the pieces on their own; for example, copy `scripts/check-docs.mjs` into any repo that follows the same doc conventions.

## Installer verification

Run `bash tests/install.sh` to check isolated copy/link installations and collision handling. The checks use temporary directories and do not modify personal skill installations. Link checks are explicitly skipped when real symlink support is unavailable (on Git Bash, use `MSYS=winsymlinks:nativestrict bash tests/install.sh`). Interactive selection should also be checked in a terminal.

## Status

New and not yet widely tested. Feedback and results are welcome.

## License

[MIT](LICENSE)
