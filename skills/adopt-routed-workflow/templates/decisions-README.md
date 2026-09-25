---
summary: Index of architecture decision records (RFCs) with status and conventions for writing new ones
read_when: Looking for the reasoning behind an implemented boundary, or writing a new RFC
---

# Decisions

Architecture decision records, written as RFCs. Each records the context, the decision, and its consequences at the time it was accepted.

| RFC | Status | Decides |
| --- | --- | --- |

## Conventions

- Number sequentially: `NNNN-short-title.md`. Start with `summary`/`read_when` front matter and add a row above.
- Header fields: Status (Proposed, Accepted, Superseded), dates, decision owners, and dependencies.
- A Proposed RFC needs the owner's acceptance before implementation.
- Once accepted, do not rewrite the decision. Record implementation status in the RFC, and put a changed decision in a new RFC that amends or supersedes the old one, noting it in both headers.
