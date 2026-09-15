# Spandrel 1.0 Specification (DRAFT)

```text
STATUS: DRAFT (INCOMPLETE SPECIFICATION ENVELOPE)
PHASE: Inception / Specification Planning
GOVERNING MAP: bd show spandrel-obn
TARGET RELEASE: Unassigned (no assumed release number; pending decision)
DATE: 2026-09-15
```

---

## 1. Scope & Purpose

Spandrel is an Event-Driven Architecture (EDA) and Domain-Driven Design (DDD) substrate for Rust applications. It is intended to provide foundational traits, envelope primitives, concurrency controllers, projection drivers, and composition patterns for building reliable, audit-grade event-sourced systems.

Spandrel 1.0 is chartered as a specification-first rewrite of the prototype `cherry-pit-*` crates developed in `Mattilsynet/gh-report`. Following the Pardosa precedent, the specification is authored and frozen before clean construction sessions begin.

### 1.1 Draft Capability Candidates (Prior Art Inventory, Not Frozen APIs)
The following candidate capabilities reflect functionality observed in donor prior art. They are subjects for specification and decision on the wayfinder map, **not finalized or frozen APIs**:
- **Domain Modeling**: Pure domain traits (`Aggregate`, `HandleCommand`, `DomainEvent`, `Command`, `Policy`, `Projection`, `EventStore`, `EventBus`, `CommandGateway`).
- **Identity & Envelopes**: Strongly-typed IDs (`AggregateId`, `IdempotencyKey`), UUIDv7/Jiff-based event envelopes (`EventEnvelope`), correlation contexts (`CorrelationContext`).
- **Command Concurrency**: Single-writer command merger holding exclusive append authority per aggregate to prevent TOCTOU concurrency conflicts.
- **Read-Side Projections**: Bounded projection drivers, event replay streams, checkpoint tracking, and snapshot storage ports.
- **Concurrency & Resource Pacing**: Bounded work queues, regulated worker pools, adaptive rate limiters, and exponential backoff mechanisms.
- **Composition**: Type-safe root application wiring combining aggregates, policies, projections, and gateways.

---

## 2. Architectural Baseline & Candidate Invariants (Planning Inputs)

Donor ADRs from `gh-report` are **planning inputs pending explicit adoption**, not automatic target authority. The wayfinder map evaluates the following candidate constraints for formal adoption:

1. **Priority Ordering (`CHE-0001` candidate)**: Correctness (1) -> Response Time (2) -> Efficiency (3). Never sacrifice deterministic correctness for raw throughput.
2. **Make Illegal States Unrepresentable (`CHE-0002` candidate)**: Invariants must be enforced by Rust type schemas (enums, newtypes, non-empty structures) rather than runtime assertion soup.
3. **Compile-Time Proof over Runtime Checking (`CHE-0003` candidate)**: Prefer compile-time type verification over runtime defensive checks.
4. **Forbid Unsafe Code (`CHE-0007` candidate)**: `#![forbid(unsafe_code)]` fleet-wide across every workspace crate with zero exceptions.
5. **Decoupled Domain Events (`CHE-0010` candidate)**: Domain events use standard Serde serialization and carry zero dependency on external storage engines or format traits.
6. **Leaf Domain Independence (`CHE-0029` candidate)**: Core domain definitions must remain an async-free, transport-free, filesystem-free leaf crate.
7. **Pardosa Externalization (`CHE-0084` candidate)**: Spandrel core crates must have ZERO direct dependency on `pardosa`. Any persistent Pardosa storage adapter lives outside the substrate core DAG.
8. **Sibling Command Concurrency (`CHE-0085` candidate)**: `App` and `Merger` are sibling concurrency primitives for different operational models; `App` must not wrap `Merger`.
9. **Elimination of Hollow Layers (`CHE-0100` candidate)**: Dead or hollow prototype abstractions (e.g. `gateway` post-msgpack retirement) are candidates for elimination during consolidation.

---

## 3. Normative Refusals (Draft Citable Non-Goals)

To prevent scope creep and maintain architectural boundaries, Spandrel draft refusals establish:

- **REF-01: Direct Database Storage**: Spandrel does not bundle database or file-format implementations in its core domain crates. Storage is defined via abstract port traits.
- **REF-02: Pardosa Core Coupling**: Spandrel does not include `pardosa` in its Cargo dependency graph.
- **REF-03: Unsafe Code**: Spandrel does not permit `unsafe` code for performance optimizations.
- **REF-04: Unbounded Resources**: Resource scope applies to triggered paths and direct resource owners (async channels, queues, buffers) with explicit items and bytes limits, timeouts, and backpressure. This does not mandate blanket no-allocation or process-wide kernel memory bounds, which are explicitly excluded.
- **REF-05: Premature Implementation**: Spandrel does not permit implementation code to be committed before the specification clauses and conformance test vectors are frozen.

---

## 4. Open Decision Holds (Governed by Wayfinder Map `spandrel-obn`)

This specification is deliberately INCOMPLETE at inception. The following decision holds are tracked as parented decision tickets under wayfinder epic `spandrel-obn`:

### Hold 1: Behavioral Inventory & Porting Scope
- **Tracker**: `bd show spandrel-obn.1`
- **Scope**: Complete behavioral and invariant extraction across `cherry-pit-core`, `cherry-pit-storage`, `cherry-pit-gateway`, `cherry-pit-merger`, `cherry-pit-projection`, `cherry-pit-web`, `cherry-pit-wq`, and `cherry-pit-app`.
- **Status**: OPEN / Unresolved.

### Hold 2: Topology and Crate Consolidation
- **Tracker**: `bd show spandrel-obn.2`
- **Scope**: Deciding whether to consolidate 8 donor crates into a streamlined multi-crate workspace (e.g. `spandrel-core`, `spandrel-storage`, `spandrel-engine`, `spandrel-projection`, `spandrel-web`, `spandrel-app`) versus a 1:1 prefix rename.
- **Status**: OPEN / Unresolved.

### Hold 3: Explicit TigerStyle Resource Contracts
- **Tracker**: `bd show spandrel-obn.3`
- **Scope**: Establishing explicit, quantified resource limits for Boundary, Budgets (items AND bytes on triggered channels/queues), Deadlines, Eviction/TTL, Backpressure, and Supervised Shutdown, while excluding allocator/runtime internals.
- **Status**: OPEN / Unresolved. Inventing arbitrary numbers without domain rationale is prohibited.

### Hold 4: Specification & Conformance Sufficiency
- **Tracker**: `bd show spandrel-obn.4`
- **Scope**: Authoring numbered, citable clauses and generating machine-readable conformance test vectors (`conformance/vectors/*.json`) derivable from the specification alone.
- **Status**: BLOCKED by Holds 1, 2, and 3.

### Hold 5: Clean Construction Admission
- **Tracker**: `bd show spandrel-obn.5`
- **Scope**: Establishing the operational protocol for admitting clean construction sessions behind the planning/construction wall.
- **Status**: BLOCKED by Hold 4.

---

## 5. Construction Gate & Conformance Requirements

Clean construction sessions may NOT be started until:
1. Holds 1 through 5 on wayfinder map `spandrel-obn` are resolved and closed with recorded rationale.
2. The normative specification clauses in this document are fully detailed and frozen.
3. Conformance test vectors are committed to `conformance/vectors/`.
4. Deterministic verification validates specification coverage and conformance readiness.
