#!/usr/bin/env python3
"""Prove a documentation migration lost nothing.

Usage: coverage.py ORIGINAL... -- NEW...

Prints every non-blank line of the original files that does not appear in the
combined new files. Whitespace, Markdown table padding, and Prettier's
*emphasis* -> _emphasis_ rewrite are ignored. Every reported line must be
accounted for: formatting only, renamed heading, rewritten link, recorded
duplicate, or approved correction of stale content.
"""
import re
import sys


def normalize(text: str) -> str:
    text = re.sub(r"(?<![*\w])\*([^*\n]+)\*(?![*\w])", r"_\1_", text)
    text = re.sub(r"\|\s*:?-{3,}:?\s*", "|---", text)
    return re.sub(r"\s+", "", text)


def main() -> int:
    if "--" not in sys.argv:
        print(__doc__)
        return 2
    split = sys.argv.index("--")
    originals, new_files = sys.argv[1:split], sys.argv[split + 1 :]
    corpus = normalize("\n".join(open(path, encoding="utf-8").read() for path in new_files))
    missing_total = 0
    for path in originals:
        missing = []
        for number, line in enumerate(open(path, encoding="utf-8").read().split("\n"), 1):
            normalized = normalize(line)
            if normalized and normalized != "---" and normalized not in corpus:
                missing.append((number, line.strip()))
        missing_total += len(missing)
        print(f"== {path}: {len(missing)} line(s) not found in the new docs")
        for number, line in missing:
            print(f"  {number}: {line[:140]}")
    return 1 if missing_total else 0


if __name__ == "__main__":
    sys.exit(main())
