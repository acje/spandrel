# Spandrel

Event-driven architecture (EDA) and domain-driven design (DDD) substrate for Rust applications. Spandrel provides foundational domain traits, event envelopes, concurrency mergers, projection drivers, and concurrency regulators for event-sourced systems.

Target user: mission-critical enterprise systems where **correctness, auditability, and deterministic concurrency matter more than raw throughput**.

## What this repo is

The **canonical home of spandrel**, in two stages:

1. **Now — the specification and conformance design.** The 1.0 specification is authored here at `docs/spec/spandrel-1.0.md` alongside conformance test vectors under `conformance/vectors/`.
2. **Later — the clean implementation and published crates.** Once clean construction sessions complete behind the planning/construction wall, this repository will host the published crates.io packages.

## spandrel 1.0 is a rewrite, not an extraction

The working prototype implementation in [Mattilsynet/gh-report](https://github.com/Mattilsynet/gh-report) under `crates/cherry-pit-*` is **reference material and prior art**. It is not being directly extracted or copied.

This follows the operational precedent established by [Pardosa](https://github.com/acje/pardosa):

- **The published structure is redesigned from scratch for external consumers**, eliminating in-tree prototype fragmentation and dead layers (such as the hollow gateway post-CHE-0100).
- **Decoupled architectural boundaries**: Invariants such as CHE-0084 (zero direct dependency on Pardosa) and CHE-0010 (serde-only domain events) are enforced from the start.
- **The transfer is clean-room, `code → spec → code`**: Planning agents extract invariants and behavior into the normative specification and conformance test vectors. Clean construction agents run in fresh sessions with **no access to donor source code or history**, proving that the specification is complete and self-sufficient.
- **Explicit TigerStyle resource contracts**: Bounded memory budgets (items AND bytes), deadlines, and backpressure policies are defined before code is written.

## Status

**Specifying.** This repo holds a [wayfinder](https://github.com/mattpocock/skills) map — a bd epic whose child tickets are the open decisions between here and clean construction admission:

```bash
bd show spandrel-obn                 # the map
bd ready --parent spandrel-obn -u    # the frontier
```

**Destination**: a written 1.0 specification and conformance suite that fixes the scope boundary, resolves crate topology, defines explicit resource contracts, and establishes clean construction admission criteria.

See `AGENTS.md` for instructions on working the map.

## Lineage

| Stage | Where | What it contributed |
|---|---|---|
| In-tree prototype | `gh-report/crates/cherry-pit-*` | 8 prototype crates: core traits, sync storage, merger channel, projections, web adapters, work queue, app wiring |
| Architectural precedent | `acje/pardosa` | Planning/construction wall, wayfinder map structure, spec-first discipline |
| 1.0 specification | this repo (`docs/spec/spandrel-1.0.md`) | Scope boundary, normative clauses, citable refusals, explicit resource contracts |
| Conformance vectors | this repo (`conformance/vectors/`) | Machine-readable test vectors derivable from specification alone |
| Clean implementation | this repo (`crates/`) | Construction sessions admitted strictly after spec freeze |

## Reference Implementation — Donor Crate Inventory

**This table describes what exists today in gh-report as prior art, not what will be published.**

| Donor Crate | Version | Role in Donor | Porting / Consolidation Disposition |
|---|---|---|---|
| `cherry-pit-core` | v0.1.0 | Pure domain traits and envelope primitives | Retain pure domain types; zero async/fs/transport dependencies |
| `cherry-pit-storage` | v0.1.0 | Synchronous atomic file writes and advisory lock | Retain low-level synchronous storage utilities |
| `cherry-pit-gateway` | v0.1.0 | Stale lock recovery helpers | Hollow post-CHE-0100; consolidate or prune |
| `cherry-pit-merger` | v0.1.0 | Single-writer command merger task/channel | Retain; specify byte bounds and deadline backpressure |
| `cherry-pit-projection` | v0.1.0 | Read-side projection driver & checkpoints | Decouple from Pardosa per CHE-0084; abstract storage port |
| `cherry-pit-web` | v0.1.0 | Axum HTTP/WS command routing | Optional web adapter; explicit request body byte limits |
| `cherry-pit-wq` | v0.2.0 | Bounded work queue, worker pool, regulators | Retain pacing engine; bounded dedup set retention and bytes |
| `cherry-pit-app` | v0.1.0 | Root composition harness | Retain wiring harness; sibling to merger per CHE-0085 |

## License

Apache-2.0 OR MIT, matching `gh-report` and `pardosa`.
