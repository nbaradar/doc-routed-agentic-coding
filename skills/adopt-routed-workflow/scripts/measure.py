#!/usr/bin/env python3
"""Estimate context size: words and tokens (characters / 4) per file and in total.

Usage: measure.py FILE...   (label estimates as estimates when reporting)
"""
import sys

total_words = total_chars = 0
for path in sys.argv[1:]:
    text = open(path, encoding="utf-8").read()
    words, chars = len(text.split()), len(text)
    total_words += words
    total_chars += chars
    print(f"{path:<60} {words:>7} words {chars // 4:>8} tokens (est.)")
print(f"{'TOTAL':<60} {total_words:>7} words {total_chars // 4:>8} tokens (est.)")
