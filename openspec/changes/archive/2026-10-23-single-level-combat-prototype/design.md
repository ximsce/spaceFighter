## Context

The repository contains product and architecture context but no runnable Godot project yet. See proposal.md for motivation and `specs/single-level-combat-prototype/spec.md` for player-visible behavior. The selected constraints are Godot 4 with GDScript, desktop-first top-down play, keyboard/mouse input, an original anime-inspired presentation, and an older Apple Silicon M1 performance baseline.

## Goals / Non-Goals

**Goals:**
- Exercise Godot's built-in scene, node, resource, and signal patterns in a small but complete gameplay loop.
- Keep encounter content, combat tuning, and visual effects bounded and easy to change during play-testing.
- Make the project easy to launch locally and inspect in the Godot editor.

**Non-Goals:**
- Establish the final multi-level run architecture, procedural generation, upgrade framework, or permanent progression.
- Build a production asset pipeline, high-end 3D rendering stack, or general-purpose level-authoring tool.
- Add online services, external runtime dependencies, or a second implementation language.

## Decisions

1. **Use a small, scene-composed Godot 4 project.** Create a game entry scene, a fixed arena scene, and reusable scenes for the player, projectiles, asteroid, hostile ship, and HUD/outcome presentation. Keep gameplay in GDScript and use Godot's built-in 2D physics, input mapping, resources, and signals. This validates the selected engine without adding framework or plugin setup. A single monolithic scene/script would be marginally faster to start but would make the architecture harder to evaluate; a custom framework or 3D renderer would add complexity without helping this prototype's goals.

2. **Keep the encounter fixed and authored.** Place a small, deliberate composition of asteroid hazards and a basic hostile ship in the arena rather than building a generator or wave system. Let the game/encounter coordinator own the active, completed, or defeated phase and objective count; let entity scenes report damage and destruction through signals. This keeps reset and outcome flow testable while avoiding a global event bus or prematurely general level model.

3. **Separate input, movement, aim, and firing.** Define named movement and primary-fire actions; movement uses keyboard input while aim follows the mouse independently. Constrain the player to the arena bounds. Use visible projectiles and collision-based damage, and make the hostile attack readable before impact. Keep health, durability, fire rate, movement speed, and related tuning values named and centralized in scene/resource configuration so play-test tuning does not imply permanent balance decisions. A shield or upgrade system is deferred.

4. **Use restrained original 2D artwork with depth cues.** Build a coherent prototype look from original local sprites or simple authored vector/shape art, distinct silhouettes, layered backgrounds, limited glow, and concise impact effects. Use 2D gameplay rather than introducing 3D models solely to achieve a 3D-esque impression. This makes the artwork immediately available and inexpensive to iterate; external asset packs could accelerate polish but add licensing and stylistic integration concerns.

5. **Treat desktop launch and M1 performance as validation targets.** Keep entity/effect counts bounded, avoid expensive full-screen effects, and provide scalable visual settings only if measurements require them. Validate a local desktop launch and the normal encounter at 1080p-equivalent rendering on the M1 baseline against the stated 30 FPS floor and 60 FPS target. Prefer native Apple Silicon export where supported. Development-machine performance alone is not sufficient evidence.

## Risks / Trade-offs

- [Prototype artwork can consume time before the combat loop is testable] → Use a deliberately small set of reusable silhouettes and effects, and prioritize gameplay readability over animation or detail.
- [A single encounter may validate only the chosen architecture's simplest path] → Keep entity boundaries and encounter coordination clear, but explicitly defer generalized route, wave, and progression systems until a later change demonstrates their need.
- [M1 performance can vary with render settings and export configuration] → Measure the exported desktop build on the target hardware, cap scene/effect complexity, and record any quality adjustment needed to meet the floor.
- [Prototype tuning may be mistaken for approved full-game balance] → Keep tuning named and local to this prototype, and treat values as test defaults rather than shared design commitments.
