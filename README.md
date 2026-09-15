# Spandrel

Modular Domain-Driven Design (DDD), Command Query Responsibility Segregation (CQRS), and Event-Driven Architecture (EDA) library components for Rust. Spandrel targets unbundled application-side primitives; it is not a monolithic application framework.

Status: Target design and specification; no Rust implementation or semantic test runner exists in this repository yet.

## Architecture & Ownership

1. **Application Layer (`gh-report`)**: Owns domain rules, command dispatch, view models, HTML rendering (Askama), and routing/auth policies.
2. **Substrate Layer (`Spandrel`)**: Practical domain traits, read ports, work queues, concurrency pacing, schedulers, storage utilities, and standard HTTP serving. Core crates maintain zero direct Cargo dependencies on Pardosa.
3. **Stream Layer (`Pardosa`)**: Append-only commit log, linearizability, CAS single-writer fencing, and BLAKE3 frame integrity.

## Core Flow & Invariants

- **Change-Driven Pipeline**: Committed stream events fold into projection state -> trigger application view rendering -> published to cache -> served via HTTP. Standard page serving resolves from cache without request-time projection queries.
- **Demarcation**: Acceptance (HTTP 202 / enqueue) != Completion != Commit. Unknown stream outcomes require reconciliation; an append error does not prove commit failure.
- **Resource Contracts**: Explicit bounds on items and owned payload/buffer heap capacity; backpressure, deadlines, and bounded shutdown are required. Allocator and kernel overhead are excluded.
- **First Implementation Target**: Minimal projection fold pilot within existing `gh-report` runtime to validate payload-first fold and stream replay equivalence.

## Documentation

- [Specification](docs/specification.md): Target contracts, recovery semantics, and neutral test fixture.
- [Components](docs/components.md): Concise mapping of the eight donor crates to Spandrel targets.
- [Architecture](docs/architecture.md): System boundaries, capability pipeline, and failure semantics.
- [Architecture Flow (HTML)](docs/architecture.html): Offline visual guide.
- [Specification Vectors](conformance/vectors/projection-fold.draft.json): Neutral key-value fold test inputs.

## License

Apache-2.0 OR MIT.
