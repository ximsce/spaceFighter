## Why

Asteroids currently behave as stationary hazards, and contact does not transfer motion, so collisions feel passive rather than physical. Giving ships and asteroids momentum-driven motion and impact feedback will make navigation and combat more legible and engaging while retaining tunable arcade handling.

## What Changes

- Add physical contact response between the player ship, hostile ships, and asteroids so colliding entities push apart and change trajectory according to their relative motion and configured physical properties.
- Apply tunable collision damage to the entities involved in impacts, with safeguards against repeated damage from a single sustained overlap.
- Give asteroids randomized initial drift within configurable direction and speed limits.
- Keep projectiles outside the physical-body collision system; they continue to use their existing hit/damage behavior.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `single-level-combat-prototype`: Require moving asteroids and momentum transfer plus impact damage when ships and asteroids collide.

## Impact

- Gameplay movement, collision, damage, and asteroid initialization in the player, hostile ship, asteroid, and arena systems.
- Existing combat encounter behavior and tests may need updates to cover moving hazards, physical response, and impact damage. No new dependencies are expected.
