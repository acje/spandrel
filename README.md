# Spandrel

Event-driven architecture (EDA) and domain-driven design (DDD) substrate for Rust applications. Spandrel provides foundational domain traits, event envelopes, concurrency mergers, projection drivers, and concurrency regulators for event-sourced systems.

Target user: mission-critical enterprise systems where **correctness, auditability, and deterministic concurrency matter more than raw throughput**.

## What this repo is

The **canonical home of spandrel**, in two stages:

1. **Now — the specification and conformance design.** The 1.0 specification is drafted here at `docs/spec/spandrel-1.0.md`. Conformance test vectors and code do not exist yet.
2. **Later — the clean implementation and published crates.** Once clean construction sessions complete behind the planning/construction wall, this repository will host the published crates.io packages.

## spandrel 1.0 is a rewrite, not an extraction

The working prototype implementation in [Mattilsynet/gh-report](https://github.com/Mattilsynet/gh-report) under `crates/cherry-pit-*` is **reference material and prior art**. It is not being directly extracted or copied.

This follows the operational precedent established by [Pardosa](https://github.com/acje/pardosa):

- **The published structure is redesigned from scratch for external consumers**, eliminating in-tree prototype fragmentation and dead layers (such as the hollow gateway post-CHE-0100).
- **Decoupled architectural boundaries**: Invariants such as CHE-0084 (zero direct dependency on Pardosa) and CHE-0010 (serde-only domain events) are considered as candidate constraints during specification.
- **The transfer is clean-room, `code → spec → code`**: Planning agents extract invariants and behavior into the normative specification and conformance test vectors. Clean construction agents run in fresh sessions with **no access to donor source code or history**, proving that the specification is complete and self-sufficient.
- **Purpose is specification sufficiency**: The purpose of the clean-room wall is design quality, specification completeness, and architectural subtraction, **NOT formal IP independence claims** (both donor and target share identical dual Apache-2.0 / MIT licensing under copyright `acje`).
- **Explicit TigerStyle resource contracts**: Bounded memory budgets (items AND bytes) on triggered channels and buffers, deadlines, and backpressure policies are defined before code is written.

## Status

**Specifying.** This repo holds a [wayfinder](https://github.com/mattpocock/skills) map — a bd epic whose child tickets are the open decisions between here and clean construction admission:

```bash
bd show spandrel-obn                 # the map
bd ready --parent spandrel-obn -u    # the frontier
```

**Destination**: a written 1.0 specification and conformance suite that fixes the scope boundary, resolves crate topology, defines explicit resource contracts, and establishes clean construction admission criteria.

See `AGENTS.md` for instructions on working the map.

## Lineage

| Stage | Where | Status / Contribution |
|---|---|---|
| In-tree prototype | `gh-report/crates/cherry-pit-*` | 8 prototype crates: core traits, sync storage, merger channel, projections, web adapters, work queue, app wiring |
| Architectural precedent | `acje/pardosa` | Planning/construction wall, wayfinder map structure, spec-first discipline |
| 1.0 specification | this repo (`docs/spec/spandrel-1.0.md`) | Draft envelope in progress; open decision holds tracked in bd |
| Conformance vectors | this repo (`conformance/vectors/`) | Planned absent; to be authored during specification phase |
| Clean implementation | this repo (`crates/`) | Planned absent; construction admitted only post-freeze |

## Reference Implementation — Donor Crate Inventory

**This table describes what exists today in gh-report as prior art, not settled published decisions.**

| Donor Crate | Version | Role in Donor | Candidate Scope / Open Decision Topic |
|---|---|---|---|
| `cherry-pit-core` | v0.1.0 | Pure domain traits and envelope primitives | Candidate for pure domain core; evaluate zero async/fs/transport dependencies |
| `cherry-pit-storage` | v0.1.0 | Synchronous atomic file writes and advisory lock | Candidate for low-level synchronous storage utilities |
| `cherry-pit-gateway` | v0.1.0 | Stale lock recovery helpers | Hollow post-CHE-0100; candidate for pruning or consolidation |
| `cherry-pit-merger` | v0.1.0 | Single-writer command merger task/channel | Candidate command-side primitive; evaluate byte bounds and backpressure |
| `cherry-pit-projection` | v0.1.0 | Read-side projection driver & checkpoints | Candidate projection driver; evaluate abstract storage port decoupling from Pardosa |
| `cherry-pit-web` | v0.1.0 | Axum HTTP/WS command routing | Candidate optional web adapter; evaluate request body byte limits |
| `cherry-pit-wq` | v0.2.0 | Bounded work queue, worker pool, regulators | Candidate pacing engine; evaluate bounded dedup set retention and bytes |
| `cherry-pit-app` | v0.1.0 | Root composition harness | Candidate wiring harness; evaluate sibling relationship to merger |

## License

Apache-2.0 OR MIT, matching `gh-report` and `pardosa`.
