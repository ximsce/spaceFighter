## Context

See proposal.md for motivation. The current player, hostile ship, and asteroids are `Area2D` nodes. The player owns a velocity but directly advances its position; the hostile ship animates its position directly; asteroids are stationary. Area overlap currently drives damage rather than a physical response. The encounter is bounded and needs to retain responsive arcade controls and the existing projectile behavior.

## Goals / Non-Goals

**Goals:**
- Add consistent momentum exchange among the player ship, hostile ship, and asteroids while preserving player steering and hostile movement intent.
- Make asteroid drift and impact response configurable and testable.
- Keep the solution lightweight for the bounded encounter and target M1 hardware.

**Non-Goals:**
- Simulating projectiles as rigid bodies or changing their damage model.
- Introducing a general-purpose simulation framework, rotation/torque simulation, or fully realistic orbital mechanics.
- Rebalancing weapons, enemy behavior, or encounter objectives beyond necessary collision tuning.

## Decisions

1. **Use one shared arcade-physics contract for the physical bodies.** Give each physical body a velocity, configured mass/radius, and collision tuning values. Combine player input acceleration and hostile movement intent with their current velocity rather than overwriting velocity or position. Asteroids receive a randomized nonzero initial velocity drawn from named minimum/maximum speed settings. A seeded random source should be injectable or otherwise controllable in tests. This maintains current movement ownership while ensuring every body responds to the same contact rules.

   **Alternative considered:** Convert all entities to `RigidBody2D`. Built-in rigid-body solving is attractive, but direct player steering, scripted hostile motion, bounded movement, and existing `Area2D` projectile detection would need additional control-mode and scene changes. A small shared arcade solver better preserves current behavior and remains easy to tune.

2. **Resolve contacts as pairwise impulses plus overlap correction.** For overlapping physical-body collision shapes, use the collision normal, relative velocity, configured masses, and restitution to apply an impulse only when bodies are approaching; correct residual overlap so bodies do not remain interpenetrating. Use a single encounter-level collision coordinator (or an equivalent shared resolver) so each pair is handled once per physics tick and pair ordering is consistent. Physical bodies bounce off arena bounds to remain in the bounded encounter.

   **Alternative considered:** Let each entity independently scan and push nearby bodies. This duplicates logic and can resolve a pair twice in one frame, producing asymmetric or unstable responses.

3. **Derive impact damage from impact severity and rate-limit it per contact.** Use relative normal impact speed and a configurable threshold/scale to calculate tunable damage to both participants. Track contact cooldown or re-arm damage only after separation, preventing a sustained overlap from draining health every frame. Keep existing projectile collision and damage paths separate. Exact mass, restitution, speed, threshold, damage scale, and cooldown values are tuning parameters to be play-tested rather than hard-coded assumptions in the specification.

   **Alternative considered:** Apply fixed damage on every overlap. This is simpler but makes low-speed grazes as harmful as hard impacts and causes repeated damage while objects remain in contact.

4. **Keep contact damage separate from damage immunity policy.** Collision response should still push bodies apart even when a ship's existing damage cooldown suppresses another health decrement. This avoids making physical motion depend on damage state and preserves the player's existing protection against rapid repeated hits.

## Risks / Trade-offs

- [Impulses can make the player feel less responsive or destabilize hostile movement] → Keep thrust/steering acceleration and damping tunable, use conservative mass/restitution defaults, and validate collisions during play-testing.
- [Frame-rate-dependent or duplicated resolution can cause jitter] → Resolve each pair once in the physics tick, use overlap correction and bounded maximum speeds, and test edge cases with multiple simultaneous contacts.
- [Random asteroid motion may make encounter difficulty inconsistent] → Bound initial speed and direction, use deterministic seeds in tests, and verify the fixed encounter remains readable and completable.
- [Impact damage can make incidental contact unexpectedly lethal] → Use an impact threshold, per-contact re-arm/cooldown, and play-testable damage scaling.

## Migration Plan

No data migration is expected. Update the existing encounter scenes/scripts and tests together; retain the existing projectile collision path. Rollback consists of restoring the previous entity movement/contact behavior and removing the shared physics resolution path.
