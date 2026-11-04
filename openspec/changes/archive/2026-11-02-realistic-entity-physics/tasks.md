## 1. Shared Physical-Body Motion

- [x] 1.1 Define shared tunable physical-body properties and velocity handling for player ships, hostile ships, and asteroids.
- [x] 1.2 Add an encounter-level resolver that detects each physical-body pair once per physics tick, applies mass/restitution-based impulses, corrects overlap, and handles arena-boundary response.
- [x] 1.3 Integrate player steering and hostile movement intent with retained velocity so both ships respond to contact without losing their movement behavior.

## 2. Asteroid Drift and Impact Damage

- [x] 2.1 Initialize each asteroid with a randomized trajectory bounded by named speed settings, with deterministic control available to tests.
- [x] 2.2 Apply configurable impact damage to both bodies based on relative impact severity, and prevent repeated damage during sustained contact while preserving physical response.
- [x] 2.3 Preserve projectile-only hit and damage behavior without adding projectile momentum exchange.

## 3. Validation and Game Documentation

- [x] 3.1 Add or update tests for randomized asteroid drift, pairwise momentum exchange, impact damage and rate limiting, arena bounds, and unchanged projectile behavior.
- [x] 3.2 Play-test movement and collision tuning for readable, responsive combat and validate performance under the encounter's normal entity load.
- [x] 3.3 Update `docs/game-design.md` to describe asteroid drift and physical ship/asteroid collision behavior.
