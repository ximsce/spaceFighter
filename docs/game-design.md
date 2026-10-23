# Space Fighter — Provisional Game Design

This document is the working product context for OpenSpec changes. It records
the smallest coherent game that satisfies the project intent. Items marked
**baseline** are working assumptions, not irreversible decisions.

## Product goal

Deliver a compact arcade run that is immediately understandable, fun to replay,
and takes an average skilled player about 15 minutes to complete. Runs should
generally fit within the broader 5–15 minute target. The player should make
moment-to-moment movement and targeting decisions while gradually becoming
stronger through a small number of meaningful upgrades.

## Confirmed direction

- **Target:** desktop executable.
- **Engine and language:** Godot 4 with GDScript.
- **Performance target:** smooth play on an older Apple Silicon M1 MacBook Pro;
  native Apple Silicon builds and scalable visual quality are preferred.
- **Gameplay perspective:** top-down 2D gameplay.
- **Presentation:** 3D or 3D-esque visuals are encouraged even though the game
  rules and play space are 2D.
- **Controls:** keyboard and mouse.
- **Art direction:** original anime-inspired space opera, reminiscent of the
  dramatic mecha, spacecraft, color, and effects language of *Macross Plus*.
  The game must use original designs and appropriately licensed assets rather
  than copying characters, ships, logos, or artwork.
- **Progression:** upgrades last for the current run only. Permanent progression
  may be considered in a future release.
- **Level structure:** gameplay uses a finite sequence of discrete levels rather
  than one seamless arena. Levels are generated or recombined into a variable
  path that culminates in a final boss. Boss levels may also appear during the
  route. There is no infinite mode in the initial release.

## Baseline assumptions

- **Perspective:** 2D, top-down arena with 3D or 3D-esque presentation.
- **Players:** one player; no online or local multiplayer in the initial scope.
- **Run structure:** a finite set of escalating generated levels with a final
  boss and clear end state.
- **Arena:** a bounded level or sequence of bounded arenas; no large open-world
  navigation.
- **Controls:** real-time movement plus keyboard/mouse aiming and firing.
- **Progression:** upgrades are primarily temporary to the current run; a
  permanent meta-progression system is not assumed.
- **Presentation:** strong readability and feedback take priority over detailed
  simulation. Anime-inspired cinematic effects are welcome when they do not
  obscure gameplay.
- **Implementation:** use Godot 4's built-in 2D/3D features and GDScript. Keep
  native extensions or additional languages out of scope unless a specific
  approved need arises.

## Core loop

1. Enter an arena or wave.
2. Fly the ship while avoiding collisions and incoming fire.
3. Fire the primary weapon to destroy asteroids, obstacles, and enemies.
4. Collect or earn an upgrade opportunity after a wave or milestone.
5. Choose an upgrade or special weapon and continue into a harder wave.
6. Finish the run by surviving the final encounter or lose when the ship is
   destroyed.

The loop should remain legible without requiring menus during active combat.
Between-wave choices are preferred for upgrades so the player can understand
the tradeoff without pausing to manage a large inventory.

## Player ship

The ship needs these baseline capabilities:

- movement with responsive acceleration and deceleration;
- a primary weapon with clear fire feedback and a controllable rate of fire;
- a shield or health model that communicates remaining survivability;
- collision and damage feedback;
- a small set of upgrade slots or choices;
- at least one special weapon or ability with a meaningful cooldown, charge, or
  limited-use constraint.

The player should always be able to tell where the ship is, where it is aiming,
whether it can fire, and how close it is to destruction.

## Threat progression

Threats should be introduced gradually rather than all appearing at once.

| Stage | Threat focus | Intended role |
| --- | --- | --- |
| Early | Asteroids and simple obstacles | Teach movement, collision avoidance, and firing |
| Middle | More varied obstacles and denser waves | Create route and target-priority decisions |
| Late | Enemy ships that can shoot back | Add pressure and force active positioning |
| Finale | Final boss encounter | Give the short run a clear climax and completion state |

The exact number of levels, route variation, and cadence of any mid-run bosses
remain open decisions. The final encounter is a required boss. Difficulty
should increase through understandable changes such as spawn density, movement
patterns, durability, and enemy fire—not arbitrary damage spikes.

## Combat and damage

- Player shots should have obvious travel, impact, and destruction feedback.
- Asteroids and obstacles should be destroyable or avoidable; indestructible
  hazards should be rare and clearly signaled.
- Enemy ships should have readable attack telegraphs and projectile behavior.
- Damage should briefly communicate its source and direction where practical.
- A run ends when the player's survivability reaches zero. The game should
  provide a fast restart path.

Exact health, shield, weapon, and timing values belong in implementation
specifications and should be exposed for tuning rather than treated as design
prose.

## Upgrades

Upgrades should change decisions without requiring a build-crafting system.
Potential categories include:

- stronger or faster primary fire;
- improved shield capacity or recovery;
- movement or thrust improvements;
- a special weapon such as a spread shot, missile, pulse, or area blast;
- defensive utility such as a short-lived barrier or emergency dash.

The initial content set should be small and distinct. Avoid upgrades that are
minor percentage variations with no noticeable play-style impact. The choice
presentation, selection rules, stacking rules, and persistence are unresolved.

## Run boundaries and pacing

The game should support:

- a brief start state with controls and objective understandable quickly;
- regular moments of escalation or reward;
- a variable but finite path to a final boss, taking an average skilled player
  about 15 minutes;
- a clear win, loss, and restart state;
- no requirement for a long tutorial, account, or multi-hour campaign.

If a feature does not improve movement, combat, survival decisions, readable
progression, or replayability within this run length, it is likely out of the
initial scope.

## Initial non-goals

Unless explicitly approved later, do not build:

- multiplayer or networking;
- a large galaxy, mission map, or open-world traversal;
- a complex inventory, crafting, shop, or economy;
- permanent character progression, accounts, or social features;
- opaque procedural generation that makes difficulty, objectives, or the route
  to the final boss unclear;
- a large roster of ships, factions, or weapons;
- elaborate cutscenes or narrative campaign systems.

## OpenSpec slicing guidance

Changes should build toward a playable vertical slice in this order, adjusting
as technical decisions are made:

1. launchable game shell, arena bounds, input, and player movement;
2. primary firing, projectiles, collisions, and one destructible asteroid;
3. survivability, damage feedback, defeat, and restart;
4. wave spawning and basic difficulty escalation;
5. upgrade choice flow and a small initial upgrade set;
6. enemy ship behavior and enemy projectiles;
7. final pacing pass, accessibility/readability pass, audio/visual polish, and
   balancing.

Each change should leave the game runnable and explain how it can be manually
play-tested.
