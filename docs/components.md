# Spandrel Component Coverage (8 Donor Crates)

Spandrel unbundles capability from eight donor crates (`cherry-pit-*`) into modular library targets. All components are target designs, not implemented crates. Donor names are reference lineage, not frozen APIs.

| Donor Crate | Target Component | Responsibility & Included Utilities |
|---|---|---|
| `cherry-pit-core` | **Domain Modeling & Read Ports** | Domain traits (`DomainEvent`, `Command`, `HandleCommand`, `Aggregate`, `Policy`), envelopes/IDs (`AggregateId`, `IdempotencyKey`, `CorrelationContext`), and query interface (`ReadPort`). `ReadPort` exposes read-only materialized projection state with no dispatch or mutation. Includes testing utilities (in-memory fake bus, test stores). |
| `cherry-pit-storage` | **Storage & Durability** | Synchronous file durability (`atomic_write_bytes` via fsync), advisory run locking (`RunLock` with TTL/heartbeat), state signature hashing (`build_snapshot_signature`), and structured persistence error models. |
| `cherry-pit-gateway` | **Recovery Utilities** | Stale lock recovery helpers (`stale_lock_evidence`) belong with storage recovery utilities; no separate gateway crate required. |
| `cherry-pit-merger` | **Command Serialization** | Optional in-process actor (`Merger`) serializing local command submissions. Local serialization alone grants no stream append authority or transaction guarantee. |
| `cherry-pit-projection` | **Read-Side Projections** | Decoupled state fold accumulators (`Projection`) and stream progress markers (`ProjectionCheckpoint`). Core maintains zero Cargo dependency on Pardosa. |
| `cherry-pit-web` | **HTTP Serving & Publication** | Axum serving pipeline (`serve`), safe path normalization, security headers, conditional ETag/304 negotiation, zstd precompression, cache snapshot load (`ServerState`), and WebSocket update broadcasts. Application owns HTML templates and auth. |
| `cherry-pit-wq` | **Concurrency & Pacing** | Bounded work queue with pending deduplication, regulated worker pool execution, batch tracking, backoff/retry/settle regulators, and rate pacers (`BudgetGate`, `TokenBucketRegulator`, `RateLimitState`, clock abstractions). |
| `cherry-pit-app` | **Scheduling, Bus & Utilities** | Generic scheduler (`DurableScheduler`) with arm/cancel/due/recovery hooks (durability depends on caller store), in-process event broadcast bus (no durable delivery guarantee), and optional dead-letter sink for unhandled failure reporting and app retry policy. |

## Demarcation Principles

1. **Application Rules**: Compiled fold priority, monotonic merge, and status ordering remain application-owned.
2. **Stream Boundaries**: Pardosa owns total commit ordering, CAS fencing, and linearizability. Spandrel core crates maintain zero direct Cargo dependencies on Pardosa, integrating via external adapter bridges.
3. **Resource Contracts**: Bounded items and owned heap capacities apply across queues, buffers, and workers.
