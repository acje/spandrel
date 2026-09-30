# Agent Instructions

Spandrel provides unbundled library components for Domain-Driven Design (DDD), Command Query Responsibility Segregation (CQRS), and Event-Driven Architecture (EDA) in Rust.

Status: Target design and specification; no Rust implementation or semantic test runner exists in this repository yet.

## Clean Construction Rule

Construction sessions operate strictly in fresh sessions with no access to donor source code or history. Implementing agents receive ONLY:
1. The canonical specification (`docs/specification.md`).
2. Neutral specification test vectors (`conformance/vectors/`).

Ambiguities must be resolved by returning to planning to clarify the specification, never by inspecting donor source.

## Verification Commands

Run verification locally from the repository root:
```bash
sh scripts/verify.sh
```
Verify relative links resolve and `docs/architecture.html` renders offline without horizontal overflow (`scrollWidth <= innerWidth` at 375px and 1280px via `agent-browser`).

## Issue Tracking

Issues are tracked using bd (`bd ready`, `bd show <id>`, `bd close <id>`). Run `bd` from this repository's root.
