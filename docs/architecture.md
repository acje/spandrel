# Spandrel Architecture Baseline

Target architectural design for the Spandrel library substrate. All components describe target capabilities; no implementation code exists in this repository yet.

## 1. Demarcation of Ownership

- **Application (`gh-report`)**: Domain business rules, command handlers, view models, HTML rendering (Askama), routing, and auth policy.
- **Substrate (`Spandrel`)**: Domain contracts, read ports, bounded queues, pacing regulators, schedulers, storage utilities, and standard HTTP serving. Core crates maintain zero Cargo dependencies on Pardosa, integrating via external adapter bridges.
- **Stream Substrate (`Pardosa`)**: Append-only commit log, CAS single-writer fencing, total commit ordering, per-fiber linearizability, and BLAKE3 frame integrity.

## 2. End-to-End Pipeline Flow

Standard page serving is change-driven and resolves from cache without request-time projection queries:

1. **Ingest & Validate**: Webhook validation and task enqueue (acceptance != completion != commit).
2. **Dispatch & Pace**: Bounded work queue dispatches to worker pool under pacing regulators (budget gate / token bucket).
3. **Decide & Propose**: Worker executes domain command (`decide(cmd, state) -> Events`); aggregates bound consistency where required.
4. **Commit & Reconcile**: Events commit via synchronous stream append above Pardosa CAS fencing. Undetermined outcomes require stream probing before assuming failure.
5. **Stream Feed (Live / Replay)**: Confirmed committed events stream incrementally to live folds or sequentially from store start during catch-up.
6. **SAME Projection Fold**: Live stream and replay catch-up process through the exact same deterministic fold logic (`apply(&mut self, payload)`).
7. **Render & Publish**: Changes trigger application view rendering; outputs are pre-compressed (zstd), ETag-hashed, and published to `html_cache` via atomic swap (`ArcSwap`).
8. **Standard HTTP Serve**: Serves cached pages directly (returning 304 on ETag match or zstd bytes) and emits WebSocket live updates only when content changes.

## 3. Reliability & Resource Semantics

- **Reconciliation**: An append error does not prove commit failure. Callers must reconcile undetermined verdicts against the stream.
- **Cursor Scope**: Dragline cursors have stream-local validity and are invalidated across migrations; durable external cursors are not guaranteed.
- **Gap & Duplicate Recovery**: Replay cutover requires explicit guards to reconcile commit-before-fold gaps and duplicate events.
- **Concurrency**: Work queue deduplication holds only while pending; dequeue removes the key. Local serialization alone grants no stream append authority or transaction guarantee.
- **Resource Contracts**: Explicit bounds on queued items and owned heap payload/buffer capacity; bounded timeouts, backpressure, and graceful shutdown are required. Memory allocation internals and OS kernel buffers are excluded.

## 4. Minimal Pilot Focus

The first implementation target will validate the decoupled payload-first `Projection` fold inside the existing `gh-report` runtime under a single-process local-file assumption, retaining the existing queue, workers, store, and server while validating commit-before-fold gap recovery, duplicate refresh semantics, and rendered-state equivalence against live stream catch-up.
