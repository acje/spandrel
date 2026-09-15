# Spandrel Specification

Target specification for Spandrel library contracts. No Rust implementation or semantic test runner exists in this repository yet.

## 1. System Invariants & Constraints

1. **Standing Priorities**: Correctness (Priority 1) -> Response Time (Priority 2) -> Efficiency (Priority 3).
2. **Type Safety & Boundary Validation**: Model domain invariants in Rust type schemas (`enums`, `newtypes`). Validate untrusted input at system boundaries; prefer compile-time structural invariants over defensive runtime checks internally.
3. **Forbid Unsafe Code**: `#![forbid(unsafe_code)]` across all target crates.
4. **Demarcation & Rules**: Application owns business rules, monotonic merge, and status anti-downgrade logic. Spandrel core crates maintain zero direct Cargo dependencies on Pardosa, integrating via external adapter bridges.
5. **Change-Driven Serving**: Projection fold -> application render -> cache publication -> HTTP serving. No mandatory request-time query stage.
6. **Recovery & Durability**:
   - Unknown commit is not failure: `Undetermined` stream verdicts require reconciliation probing; an append error does not prove commit loss.
   - Stream cursors are stream-local and invalidated on migration; no process-spanning durable cursors are assumed.
   - Schedulers provide generic arm/cancel/due/recovery hooks; actual durability depends on caller-provided storage ports. In-memory bus and scheduler stores carry no durable delivery guarantee.
7. **Resource Contracts**: Callers configure explicit limits on concurrent items and owned heap capacity (payloads and buffers). Backpressure, deadlines, and bounded shutdown are required. Memory allocator overhead, runtime engine allocations, and kernel structures are excluded.
8. **Replay, Consistency & Publication Semantics**:
   - Replay Equivalence: Historical replay and live streaming must yield equal projection state at the same committed state.
   - Consistent Snapshots: Saved projection state and stream checkpoint cursors must form an atomic, consistent pair.
   - Cutover Recovery: Transition from catch-up replay to live streaming requires cutover guards outside the fold to reconcile commit-before-fold gaps and duplicate events.
   - Coherent Memoization: Pre-rendered caches must version view models, templates, and config; publish coherent snapshots; retain the last valid snapshot on render failure; and notify subscribers only on content/ETag change.
   - Bus Delivery Failures: In-process event bus delivery failures and subscriber lag must be surfaced explicitly; no durable delivery is inferred.

## 2. Target Component Surface

Names outside the `Projection` pilot are illustrative reference names, not fixed public signatures:
- **Domain & Commands**: Illustrative candidate traits (`DomainEvent`, `Command`, `HandleCommand`, `Policy`). Aggregates provide transactional boundaries only where invariants require them; exact signatures and serialization models are caller-defined.
- **Read Ports**: `ReadPort` exposes read-only materialized projection state with no command dispatch, history replay, or mutation.
- **Identity & Transport**: `AggregateId`, `IdempotencyKey`, `CorrelationContext`, and `EventEnvelope`. Projections fold domain payloads directly without forced envelope synthesis.
- **Concurrency & Pacing**: `WorkQueue` (pending deduplication, bounded items and heap bytes), worker pool supervisors, batch tracking, backoff/retry/settle policies, and rate pacing (`BudgetGate`, `TokenBucketRegulator`, `RateLimitState`).
- **Command Serialization**: Optional local actor (`Merger`); local serialization alone grants no stream append authority or transaction guarantee.
- **Storage & Recovery**: `atomic_write_bytes` (fsync durability), advisory `RunLock` with TTL, snapshot hashing (`build_snapshot_signature`), and structured persistence error models.
- **HTTP Serving**: Generic Axum pipeline (`serve`), path normalization, security headers, conditional ETag/304 negotiation, zstd precompression, cache snapshot access (`ServerState`), and WebSocket update broadcast. Application owns HTML rendering.
- **Utilities**: Testing fakes/clocks, dead-letter sink for unhandled failure reporting and application retry policy.

## 3. Projection Fold Specification Clauses

### PROJ-01: Decoupled Projection Trait Definition
The `Projection` contract defines a read-side state accumulator over a typed event payload, decoupled from transport and storage envelopes:
```rust
pub trait Projection {
    type Payload;
    fn apply(&mut self, payload: &Self::Payload);
}
```

### PROJ-02: Payload-First Infallible Fold Contract
The fold operation `apply(&mut self, payload: &Self::Payload)` defines an infallible signature contract returning `()`. The projection borrows the event payload, preventing ownership transfers. The contract guarantees the trait signature returns `()`, but does not guarantee third-party fold bodies are panic-free or allocation-free.

### PROJ-03: Separation of Boundary Errors
Stream deserialization and transport validation must occur at the stream boundary before invoking `apply`. The fold assumes passed payloads are admitted; the library trait does not embed sequence-gap detection.

### PROJ-04: Application-Owned Metadata & Status Ordering
Metadata attributes (stream sequences, timestamps, correlation IDs) belong to envelopes and readers. Read-model status conflict resolution and anti-downgrade heuristics are application-owned fold logic.

### PROJ-05: Resource Demarcation
The `Projection` trait owns zero queues, background tasks, or payload retention. Callers retain complete ownership of projection state and allocation policy.

### PROJ-06: Neutral Test Fixture Definition (Simple Key-Value Map)
The neutral specification fixture is defined as:
1. **State**: Finite string map: $\text{State} = \{ k \mapsto v \mid k \in \text{String}, v \in \text{String} \}$. Initial state $\text{State}_0 = \{\}$.
2. **Events**: `Set { key: String, value: String }` and `Remove { key: String }`.
3. **Transition Rules**:
   - $\text{apply}(\text{State}, \text{Set}(k, v)) \implies \text{State} \cup \{ k \mapsto v \}$ (overwrites existing key).
   - $\text{apply}(\text{State}, \text{Remove}(k)) \implies \text{State} \setminus \{ k \}$ (absent key is an infallible no-op).
4. **Equivalence & Determinism**: Two states are equal if and only if they contain the identical set of key-value pairs. Replaying identical events from $\text{State}_0$ yields identical state. Transitions are order-sensitive.

Input test scenarios are provided in [`conformance/vectors/projection-fold.draft.json`](../conformance/vectors/projection-fold.draft.json).

## 4. Feedback Pilot

A minimal projection fold adapter in `gh-report` will validate the payload-first contract and replay equivalence under single-process local-file operation while retaining the existing queue, workers, store, and server, verifying gap recovery, duplicate refresh semantics, and rendered-state equivalence before library construction.
