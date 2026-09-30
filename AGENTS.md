# Agent Instructions — spandrel

Repo-specific operational notes. General agent/OODA doctrine, bash hygiene,
and the Rust no-`//`-comments house style live in the global
`~/.config/opencode/AGENTS.md` (auto-loaded) — not repeated here.

## Section 1: Canonical Fleet Doctrine

### OODA Loop Roles
- **Copernicus** (Observe): Raw evidence gathering from environment, code, and external specs. Pure sensor; produces no hypotheses.
- **Feynman** (Orient): Produces ranked hypotheses with falsifiers; stress-tests against concrete examples.
- **Moltke** (Decide): Standing mission commander. Emits executable mission contracts, sets intent, boundaries, and abort criteria.
- **Hopper** (Act): Executes missions using Kent Beck TDD (red-green-refactor) with verify-before-claim discipline.
- **Linus** (Review): Mandatory pre-merge Rust reviewer for idiom conformance, type safety, unsafe soundness, and supply chain.
- **Hamilton** (Assurance): Architectural alignment and assurance reviewer running during CI wait windows.
- **Gardener** (GC): Post-mission cleanup specialist; reclaims transient scaffolding and closes completed mission beads.

### Priority Hierarchy
Tradeoffs strictly resolve in this five-tier priority order:
1. **Maintainability**: Pure trunk development, small deployable increments, minimal cognitive overhead, low complexity.
2. **Correctness by design**: Make illegal states unrepresentable via types, explicit state machines, and private invariant constructors.
3. **Response times**: Latency-sensitive read paths and prompt fact propagation across boundaries.
4. **Energy efficiency in code**: Minimize redundant polling, hot loops, unnecessary serialization, and idle CPU/memory burn.
5. **Features**: New functionality ranks last and must never compromise the higher tiers.

### Non-Interactive Shell Commands & Bash Hygiene
Subagents execute non-interactively. Commands that prompt for user confirmation stall execution indefinitely.
- Always use non-interactive and force flags: `cp -f`, `rm -f`, `rm -rf`.
- Streaming and batch mode: use `--batch`, `-y`, or `--quiet` where available.
- Stream separation: machine-readable findings route to `stdout`; diagnostics and logs route to `stderr`.

### Zero Plain Comments
In Rust source (`*.rs`), plain comments (`//` or `/* */`) are forbidden.
- Rationale belongs in commit messages, ADRs, or bead descriptions.
- Use `///` or `//!` contract doc-comments only when defining public API documentation (with required `# Errors`, `# Panics`, `# Safety` sections).
- Suppress lints with `#[expect(lint, reason = "...")]` rather than plain comments.

### Doctrine: "Make tools fast to iterate fast"
Developer and verification tooling must be compiled, ultra-fast Rust binaries operating directly on ASTs and files rather than slow interpreted wrappers or token-heavy in-context simulation. Fast tools enable high-frequency local feedback loops (INNER cadence) without friction.

### Doctrine: "Zero compliance theatre"
High-assurance testing techniques—such as property-based testing (proptest), fuzzing (cargo-fuzz), formal model checking, or fault injection—must be applied purposefully at critical serialization, concurrency, and storage boundaries (high-risk seams), not sprayed ubiquitously as box-ticking ceremony. Where type invariants and deterministic unit tests suffice, do not add compliance overhead.

## Section 2: Target-Specific Profile

### Target Classification & Specification Scope
- Target class: `specification` (as mapped in `sf-sdlc.toml`).
- Spandrel provides unbundled library components for Domain-Driven Design (DDD),
  Command Query Responsibility Segregation (CQRS), and Event-Driven Architecture (EDA) in Rust.
- Status: Target design and specification; no Rust implementation or semantic test
  runner exists in this repository yet.

### Clean Construction Rule
Construction sessions operate strictly in fresh sessions with no access to donor source code or history. Implementing agents receive ONLY:
1. The canonical specification (`docs/specification.md`).
2. Neutral specification test vectors (`conformance/vectors/`).

Ambiguities must be resolved by returning to planning to clarify the specification, never by inspecting donor source.

### Verification Entrypoint
Run verification locally from the repository root:
```bash
sh scripts/verify.sh
```
Verify relative links resolve and `docs/architecture.html` renders offline without horizontal overflow (`scrollWidth <= innerWidth` at 375px and 1280px via `agent-browser`).

### TigerStyle Construction-Path Inventory
When implementation commences, invariant-bearing domain types must enforce "illegal states unrepresentable" by design across all construction and mutation routes.

### Issue Tracking & Database Discovery
Issues are tracked using bd (`bd ready`, `bd show <id>`, `bd close <id>`).
- Database: repo-local store at `.beads/embeddeddolt`.
- Pinned store discovery: use `bd -C <repo-root>` to target this repository directly.
- Autonomous commits follow `~/.config/opencode/AGENTS.md § Commits — agent-driven by default`.
