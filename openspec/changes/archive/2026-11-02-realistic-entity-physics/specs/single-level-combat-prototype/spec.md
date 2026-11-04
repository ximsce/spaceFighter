## MODIFIED Requirements

### Requirement: Fight hazards and a hostile ship
The encounter SHALL include destructible asteroid hazards and at least one hostile ship that can attack the player, and player fire SHALL be able to damage and destroy both threat types. The player ship, hostile ship, and asteroids SHALL move as physical bodies: contact between any pair SHALL push them apart and change their trajectories according to their relative motion and physical properties, and an impact SHALL be capable of damaging both bodies. Asteroids SHALL begin with randomized drift within configured direction and speed limits. Projectiles SHALL retain their existing hit-and-damage behavior and SHALL NOT participate as physical bodies.

#### Scenario: Destroy an asteroid
- **WHEN** player fire hits a destructible asteroid
- **THEN** the asteroid shows a hit response and is removed when its tunable durability is depleted

#### Scenario: Damage a hostile ship
- **WHEN** player fire hits the hostile ship
- **THEN** the hostile ship shows a hit response and is destroyed when its tunable durability is depleted

#### Scenario: Asteroids begin moving
- **WHEN** the encounter starts
- **THEN** each asteroid moves on an initial randomized trajectory with a speed within the configured asteroid drift limits

#### Scenario: Exchange momentum on contact
- **WHEN** the player ship, hostile ship, or an asteroid collides with another of those physical bodies
- **THEN** the bodies separate, and both trajectories change according to their relative motion and configured physical properties

#### Scenario: Take impact damage
- **WHEN** two physical bodies collide with sufficient relative impact speed
- **THEN** both bodies receive tunable impact damage, without repeated damage being applied continuously for the same sustained contact

#### Scenario: Projectiles remain non-physical
- **WHEN** a projectile hits a ship or asteroid
- **THEN** it applies its existing hit-and-damage behavior without participating in momentum exchange

#### Scenario: Avoid hostile fire
- **WHEN** the hostile ship attacks
- **THEN** its attack is visibly readable in time for the player to react, and a hit can damage the player ship
