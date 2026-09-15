# Agent Instructions

## Resuming the spandrel 1.0 spec work

This repository's active work is a **wayfinder map** — a bd epic whose child tickets are the open decisions between inception and clean construction admission for the Spandrel library. To work the map:

1. Load the skill: `skill({ name: "wayfinder" })`, and use its **"Work through the map"** mode.
2. Read the map: `bd show spandrel-obn`. This is the low-resolution view — destination, standing constraints, decisions already made, fog, and what is out of scope. Read it before choosing anything.
3. Take the next frontier ticket: `bd ready --parent spandrel-obn -u`, then claim it with `bd assign <id> <you>` **before** doing any work.
4. Resolve one ticket per session (research tickets are the exception — those may be batched). Record the answer with `bd comment <id>`, close with `bd close <id> --reason "<gist>"`, and add a one-line entry to the map's Decisions-so-far via `bd update spandrel-obn --stdin` (using the safe accumulation recipe).

**Run `bd` from this repository's directory.** bd resolves its workspace from the current directory (`/Users/anders.jensen/Documents/github/Mattilsynet/spandrel`).

Ticket types carry a `wayfinder:<type>` label. `research` is AFK — dispatch `copernicus` via Task. `grilling` is HITL — it requires human conversation.

Reference material for the specification lives in the sibling `gh-report` checkout under `crates/cherry-pit-*`, and is reference material rather than code to be copied.

## The Planning / Construction Wall

Spandrel follows the clean-room specification and construction precedent established by Pardosa (`pardosa/docs/plans/pardosa-0.5.1.md`):

1. **Inside the Wall (Planning Sessions)**:
   - Planning agents inspect donor `cherry-pit-*` crates in `gh-report`.
   - Evaluate candidate architectural invariants and extract behavior into `docs/spec/spandrel-1.0.md`.
   - Author machine-readable conformance test vectors under `conformance/vectors/`.
2. **Outside the Wall (Clean Construction Sessions)**:
   - Construction sessions operate strictly in fresh sessions with **no access to donor source code**.
   - Implementing agents receive ONLY:
     - The canonical specification (`docs/spec/spandrel-1.0.md`).
     - Derivable conformance test vectors (`conformance/vectors/`).
   - Neither donor source, nor donor git history, nor planning scratch files cross into construction sessions.
   - Purpose is specification sufficiency and design quality, **not formal IP independence claims**.
   - If an implementation ambiguity arises, it is resolved by returning to planning inside the wall to clarify the specification, never by inspecting donor source.

## Inception Verification Commands

During the inception and specification planning phase, verify repository health and remote isolation with the following actual local commands:

```bash
# Inner tier (working tree health)
git diff --check
git status --short

# Mid tier (object integrity and remote isolation)
git fsck --no-reflogs
gh repo view acje/spandrel --json nameWithOwner,visibility,url,isEmpty

# Boundary tier (history and remote wiring)
git log -1 --oneline
git remote -v
```

No semantic test suite or `spec-coverage` binary exists in this repository yet; those will be introduced as deliverables of the specification phase before construction is admitted.

## Issue Tracking

This project uses **bd (beads)** for issue tracking. Run `bd prime` for full workflow context.

> **Architecture in one line:** Issues live in a local Dolt database (`.beads/embeddeddolt`); sync uses `refs/dolt/data` on git remote `origin` (`https://github.com/acje/spandrel.git`).

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work atomically
bd close <id>         # Complete work
```

### Git and Commit Policy

Per fleet doctrine in `~/.config/opencode/AGENTS.md` (§ Commits — agent-driven by default):
- Commit autonomously when the work was in scope, verification passed, and the working tree contains only intended changes.
- Push remains user-driven; do not push to `origin` without explicit user instruction.
