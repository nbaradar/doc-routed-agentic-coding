#!/usr/bin/env node
// Documentation checks for the documentation-routed workflow.
// Dependency-free: run with `node scripts/check-docs.mjs` from the repo root.
// Exits non-zero and lists every problem when the docs drift.

import { existsSync, readdirSync, readFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";

// ---- Configuration: adjust per project -----------------------------------
const config = {
  docsDir: "docs",
  // Directories under docsDir that are never documentation (e.g. private exports).
  ignoredDirectories: new Set(["node_modules"]),
  // Index files; every doc under docsDir must be linked from one of them.
  indexFiles: ["docs/README.md", "docs/plans/README.md"],
  // Top-level files whose relative links must resolve.
  topLevelFiles: ["AGENTS.md", "PLAN.md", "README.md"],
  // The always-loaded contract whose backticked `*.md` paths must exist.
  contractFile: "AGENTS.md",
  // Claude Code entry point that must import the contract (null to skip).
  claudeFile: "CLAUDE.md",
  plansDir: "docs/plans",
  statusFile: "docs/status.md",
  planStatuses: ["Draft", "Approved", "In progress", "Done", "Superseded"],
};
// ---------------------------------------------------------------------------

const problems = [];
const fail = (message) => problems.push(message);

function markdownFiles(directory) {
  if (!existsSync(directory)) return [];
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) {
      return config.ignoredDirectories.has(entry.name) ? [] : markdownFiles(path);
    }
    return entry.name.endsWith(".md") ? [path] : [];
  });
}

function relativeLinks(markdown) {
  return [...markdown.matchAll(/\]\(([^)\s]+)\)/gu)]
    .map((match) => match[1])
    .filter((target) => !/^[a-z]+:/iu.test(target) && !target.startsWith("#"))
    .map((target) => target.split("#")[0]);
}

const docs = markdownFiles(config.docsDir);

// 1. Front matter on every doc.
for (const file of docs) {
  const source = readFileSync(file, "utf8");
  if (!/^---\nsummary: .+\nread_when: .+\n---\n/u.test(source)) {
    fail(`${file}: needs "summary" and "read_when" front matter`);
  }
}

// 2. Every doc is indexed.
const indexed = new Set();
for (const indexFile of config.indexFiles) {
  if (!existsSync(indexFile)) {
    fail(`${indexFile}: index file is missing`);
    continue;
  }
  for (const target of relativeLinks(readFileSync(indexFile, "utf8"))) {
    indexed.add(join(dirname(indexFile), target));
  }
}
for (const file of docs) {
  if (config.indexFiles.includes(file) && file === join(config.docsDir, "README.md")) continue;
  if (!indexed.has(file)) fail(`${file}: not listed in any index (${config.indexFiles.join(", ")})`);
}

// 3. Relative links resolve.
for (const file of [...config.topLevelFiles.filter(existsSync), ...docs]) {
  for (const target of relativeLinks(readFileSync(file, "utf8"))) {
    const resolved = join(dirname(file), target);
    if (!existsSync(resolved)) fail(`${file}: links to missing ${relative(".", resolved)}`);
  }
}

// 4. Paths named in the contract exist.
if (existsSync(config.contractFile)) {
  const contract = readFileSync(config.contractFile, "utf8");
  for (const [, path] of contract.matchAll(/`([\w./-]+\.md)`/gu)) {
    if (path.includes("<") || path.includes("NNNN")) continue;
    if (!existsSync(path)) fail(`${config.contractFile}: names missing ${path}`);
  }
} else {
  fail(`${config.contractFile}: missing`);
}

// 5. CLAUDE.md imports the contract.
if (config.claudeFile && existsSync(config.claudeFile)) {
  const claude = readFileSync(config.claudeFile, "utf8");
  if (!claude.includes(`@${config.contractFile}`)) {
    fail(`${config.claudeFile}: must import @${config.contractFile}`);
  }
}

// 6. Plan statuses.
const plans = existsSync(config.plansDir)
  ? readdirSync(config.plansDir)
      .filter((name) => /^\d{4}-.+\.md$/u.test(name))
      .map((name) => {
        const source = readFileSync(join(config.plansDir, name), "utf8");
        return {
          name,
          status: /^- Status: (.+)$/mu.exec(source)?.[1],
          openQuestions: /^## Open questions\n([\s\S]*?)^## /mu.exec(source)?.[1] ?? "",
        };
      })
  : [];
const planIndexPath = join(config.plansDir, "README.md");
const planIndex = existsSync(planIndexPath) ? readFileSync(planIndexPath, "utf8") : "";
for (const plan of plans) {
  if (!config.planStatuses.includes(plan.status)) {
    fail(`${plan.name}: invalid status "${plan.status}" (expected ${config.planStatuses.join(", ")})`);
  }
  const row = planIndex.split("\n").find((line) => line.includes(`](${plan.name})`));
  if (!row) fail(`${plan.name}: missing from ${planIndexPath}`);
  else if (!row.split("|").map((cell) => cell.trim()).includes(plan.status)) {
    fail(`${plan.name}: status in ${planIndexPath} does not match "${plan.status}"`);
  }
  if (!["Draft", "Superseded"].includes(plan.status) && !/^(?:None\.?)?$/u.test(plan.openQuestions.trim())) {
    fail(`${plan.name}: is ${plan.status} but still has open questions`);
  }
}
const inProgress = plans.filter((plan) => plan.status === "In progress");
if (inProgress.length > 1) {
  fail(`more than one plan is In progress: ${inProgress.map((plan) => plan.name).join(", ")}`);
}
const status = existsSync(config.statusFile) ? readFileSync(config.statusFile, "utf8") : "";
for (const plan of inProgress) {
  if (!status.includes(`plans/${plan.name}`)) fail(`${config.statusFile}: must link in-progress plan ${plan.name}`);
}

if (problems.length > 0) {
  console.error(`Documentation checks failed (${problems.length}):`);
  for (const problem of problems) console.error(`  - ${problem}`);
  process.exit(1);
}
console.log(`Documentation checks passed (${docs.length} docs, ${plans.length} plans).`);
