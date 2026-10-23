# Single-Level Combat Prototype Specification

## Purpose

Provide a small, runnable combat encounter that demonstrates the agreed Space Fighter gameplay direction and gives the team a concrete prototype for validating its initial technical architecture.

## Requirements

### Requirement: Play one bounded combat encounter
The prototype SHALL launch into one fixed, bounded arena encounter that can be completed, lost, and replayed without navigating a multi-level route.

#### Scenario: Start the prototype
- **WHEN** the user launches the desktop game
- **THEN** the prototype presents the player ship in the single combat arena with the encounter objective and controls understandable without a separate tutorial

#### Scenario: Stay within the arena
- **WHEN** the player steers toward an arena boundary
- **THEN** the ship remains within the playable area and the boundary is visually legible

### Requirement: Pilot and fire the player ship
The prototype SHALL support responsive keyboard movement, mouse-directed aiming, and a primary weapon controlled independently from movement.

#### Scenario: Move and aim
- **WHEN** the player presses the configured movement keys and moves the mouse
- **THEN** the ship moves within the arena and visibly aims toward the mouse cursor

#### Scenario: Fire the primary weapon
- **WHEN** the player uses the configured primary-fire input
- **THEN** a visible projectile travels from the player ship in the aimed direction and provides readable firing and impact feedback

### Requirement: Fight hazards and a hostile ship
The encounter SHALL include destructible asteroid hazards and at least one hostile ship that can attack the player, and player fire SHALL be able to damage and destroy both threat types.

#### Scenario: Destroy an asteroid
- **WHEN** player fire hits a destructible asteroid
- **THEN** the asteroid shows a hit response and is removed when its tunable durability is depleted

#### Scenario: Damage a hostile ship
- **WHEN** player fire hits the hostile ship
- **THEN** the hostile ship shows a hit response and is destroyed when its tunable durability is depleted

#### Scenario: Avoid hostile fire
- **WHEN** the hostile ship attacks
- **THEN** its attack is visibly readable in time for the player to react, and a hit can damage the player ship

### Requirement: Communicate survivability and encounter outcomes
The prototype SHALL communicate player survivability during combat and provide distinct completion and defeat states with a fast restart path.

#### Scenario: Complete the encounter
- **WHEN** the player destroys all hostile ships in the fixed encounter
- **THEN** the game presents a clear completion state and an option to restart the encounter

#### Scenario: Lose the encounter
- **WHEN** incoming damage depletes the player ship's survivability
- **THEN** the game stops active combat, presents a clear defeat state, and offers a restart

#### Scenario: Restart after an outcome
- **WHEN** the player chooses restart from a completion or defeat state
- **THEN** the same encounter resets to its initial player, hazard, enemy, and survivability state

### Requirement: Establish readable original prototype artwork
The prototype SHALL use original, locally available artwork for the player ship, hostile ship, hazards, projectiles, and arena presentation, with visual distinctions sufficient to read movement, aiming, attacks, damage, and outcomes during play.

#### Scenario: Read combat in the arena
- **WHEN** the player is moving and combat effects are active
- **THEN** the player ship, hostile ship, asteroid hazards, and hostile projectiles remain visually distinguishable from one another and the arena background

#### Scenario: Use original art assets
- **WHEN** the prototype is run
- **THEN** its presented art is original prototype material or properly licensed material and does not reproduce protected franchise characters, ships, logos, or artwork

### Requirement: Run on the selected desktop baseline
The prototype SHALL run as a local Godot desktop game without requiring an internet connection, and its bounded encounter SHALL remain playable on the project’s older Apple Silicon M1 baseline at 1080p-equivalent rendering with a 30 FPS floor and a 60 FPS target where supported.

#### Scenario: Play on the baseline hardware
- **WHEN** the encounter is run on the stated M1 baseline at 1080p-equivalent rendering
- **THEN** the prototype remains playable at no less than 30 FPS under normal encounter load, targeting 60 FPS where supported
