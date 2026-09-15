# Precedent: Spandrel Clean Specification and Construction

## 1. Lineage and Precedent Model

Spandrel is an event-driven architecture (EDA) and domain-driven design (DDD) substrate for Rust applications. It is chartered as a specification-first, clean-room reconstruction of the event-sourcing and concurrency primitives developed as `cherry-pit-*` within `Mattilsynet/gh-report`.

This inception follows the proven operational precedent established by **Pardosa** (`acje/pardosa`, documented in `pardosa/docs/plans/pardosa-0.5.1.md` and governed by wayfinder map `pardosa-jn1`):

1. **Prototype phase in donor repo**: Initial prototype crates were incubated inside `gh-report` (`crates/cherry-pit-*`).
2. **Independent sibling repository inception**: A separate repository is created with its own git history, dual licensing (`MIT OR Apache-2.0`, copyright `acje`), and public remote namespace (`https://github.com/acje/spandrel.git`).
3. **Specification-first wayfinder phase**: A durable wayfinder map (`spandrel-obn`) resolves architectural decisions and authors a self-contained normative specification (`docs/spec/spandrel-1.0.md`) and conformance test vectors (`conformance/vectors/*.json`) before any implementation code is written.
4. **Clean construction wall**: Construction sessions run in fresh environments receiving only the specification and conformance vectors.
5. **Crate consolidation**: Accidental complexity and in-tree prototype fragmentation are pruned into a cohesive published crate structure.
6. **Downstream cutover**: Once verified against conformance vectors, downstream consumers (`gh-report`) switch dependency manifests to the clean repository and retire donor prototype crates.

## 2. The Planning / Construction Wall

The wall separates specification planning from clean construction:

```
[ Inside the Wall: Planning ]
  - Inspect donor code: gh-report/crates/cherry-pit-*
  - Review donor ADRs: CHE-0001 .. CHE-0102
  - Author normative specification: docs/spec/spandrel-1.0.md
  - Author conformance test vectors: conformance/vectors/*.json
               │
               ▼
   [ The Wall: Strict Boundary ]
               │  Only two authorized carriers cross:
               │  1. Canonical specification document
               │  2. Derivable conformance test vectors
               ▼
[ Outside the Wall: Construction ]
  - Fresh sessions, zero donor access
  - No cherry-pit source code
  - No donor git history or planning scratch
  - TDD implementation driven by conformance suite
```

### Sufficiency over Independence

As recorded in Pardosa precedent (`pardosa/docs/plans/pardosa-0.5.1.md:43-44` and `pardosa-jn1.78`):
> *"The purpose is design quality and specification sufficiency, not an IP claim."*
> *"The founding claim survives because the test is SUFFICIENCY, not INDEPENDENCE."*

Both the donor repository (`Mattilsynet/gh-report`) and target (`acje/spandrel`) share dual MIT / Apache-2.0 licensing under identical copyright (`acje`). There is no external copyright hazard. The discipline of the wall exists because:
- If an agent can implement the library solely from the specification and conformance vectors, the specification is complete.
- Bypassing the specification to copy donor code reproduces unratified invariants, hollow abstractions, and accidental complexity.

## 3. Donor Source Baseline (cherry-pit Crates)

The donor substrate in `gh-report/crates/` consists of eight crates:

| Donor Crate | Version | Role in Donor | Precedent Analysis |
|---|---|---|---|
| `cherry-pit-core` | v0.1.0 | Pure domain traits (`Aggregate`, `HandleCommand`, `DomainEvent`, `EventStore`), types (`AggregateId`, `EventEnvelope`), error models | Pure domain leaf crate. Zero async/transport dependencies (CHE-0029). Retain core abstractions. |
| `cherry-pit-storage` | v0.1.0 | Synchronous filesystem primitives (`atomic_write_bytes`, `ProcessLock`) | Synchronous I/O (`std::fs`, `tempfile`). No tokio dependency (CHE-0055). Retain as low-level storage utility. |
| `cherry-pit-gateway` | v0.1.0 | Infrastructure recovery helpers (`stale_lock_evidence`) | Hollowed out post-CHE-0100 (msgpack retired). Zombie crate; prune or merge into composition/storage. |
| `cherry-pit-merger` | v0.1.0 | Single-writer command merger task/channel resolving TOCTOU races (CHE-0069) | Essential command-side concurrency primitive. Requires explicit byte budget and deadline contract. |
| `cherry-pit-projection` | v0.1.0 | Read-model projection driver, checkpointing, snapshot port (CHE-0048) | Violates CHE-0084 by directly depending on `pardosa`. Must decouple: projection depends only on abstract trait port. |
| `cherry-pit-web` | v0.1.0 | Axum HTTP/WS adapter for command routing and projection serving | Optional web adapter layer. Requires explicit request body byte bounds. |
| `cherry-pit-wq` | v0.2.0 | Concurrency and pacing: work queue, worker pool, token-bucket regulator (CHE-0055) | Concurrency engine. Requires bounded deduplication retention and byte accounting. |
| `cherry-pit-app` | v0.1.0 | Root composition wiring Aggregate/Policy/Projection against ports (CHE-0085) | High-level wiring harness. Sibling to merger (App does not wrap merger per CHE-0085). |

## 4. Key Architectural Lessons from Precedent

1. **Severing External Substrate Dependencies (`CHE-0010`, `CHE-0084`)**:
   In `gh-report`, `cherry-pit-projection` took a direct dependency on `pardosa`, violating architectural rules. In Spandrel, `spandrel` core crates must have ZERO dependency on `pardosa`. Persistent storage adapters belong in decoupled adapter crates or downstream consumers.
2. **Eliminating Hollow Crates (`CHE-0100`)**:
   Avoid literal 1:1 prefix renaming that blindly preserves dead abstractions like `gateway`. Consolidate along principled boundaries.
3. **Explicit TigerStyle Resource Contracts**:
   Donor crates established item bounds (e.g. 1024 merger items) but lacked byte limits, deduplication set retention TTLs, and streaming replay limits. Spandrel specifies items AND bytes, deadlines, and backpressure policies before code is written.
