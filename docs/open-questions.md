# Open Questions

This document separates confirmed decisions from unresolved questions. Answering
the remaining questions will let future OpenSpec changes use concrete
requirements instead of assumptions.

## Confirmed decisions

- Engine and language: Godot 4 with GDScript. This is the selected stack for
  initial development; other engines/languages below are alternatives considered
  and are not current plans.
- Target platform: desktop executable.
- Performance constraint: the game must run smoothly on an older Apple Silicon
  M1 MacBook Pro; native Apple Silicon builds and scalable visual quality are
  preferred.
- Gameplay: top-down 2D with 3D or 3D-esque presentation.
- Controls: keyboard and mouse.
- Art direction: original anime-inspired space opera reminiscent of
  *Macross Plus*; no unlicensed copied assets or designs.
- Progression: upgrades are run-local for the initial release.
- Structure: a finite sequence of generated or recombined discrete levels with
  a variable path to a required final boss; occasional mid-run boss levels are
  possible, but there is no infinite mode in the initial release.
- Pacing: an average skilled player should complete the route in about 15
  minutes, within the broader 5–15 minute target.

## Technical foundation

1. **Should the game require an internet connection or use any external
   services?**
   - Recommended default: no; the game should run locally.

2. **What performance target and baseline display resolution should be used for
   acceptance testing?**
   - Recommended default: target 60 FPS where the display supports it, maintain
     a stable 30 FPS floor, and test at 1080p-equivalent rendering on the M1
     MacBook Pro with quality settings available if needed.

## Game feel and presentation

3. **What visual and audio details should support the anime space-opera
   direction?**
   - The broad direction is decided; remaining choices include cel shading,
     sprite-based 2.5D, low-poly models, UI typography, music, and voice.

## Run design

4. **How many regular levels should a generated route contain, and how much
   should routes vary?**
   - Recommended default: 4–6 regular levels plus a final boss, with bounded
     variations in level type, hazards, and encounter order.
5. **How often should optional mid-run boss levels occur?**
   - Recommended default: at most one mid-run boss before the final boss,
     subject to play-testing the 15-minute pacing.
6. **Should the arena wrap at screen edges or have solid boundaries?**
   - Recommended default: solid readable boundaries; no wrap until play-testing
     demonstrates a need for it.
7. **Should upgrades be selected between levels, dropped during combat, or
   both?**
   - Recommended default: choose one of a few upgrades between waves, with no
     inventory management.
8. **How should the final boss affect the completion-time target?**
   - Recommended default: reserve roughly 2–3 minutes of the average 15-minute
     run for the final encounter, with a fast restart after defeat.

## Product constraints

9. **What is the target audience and expected difficulty?**
    - For example: casual first-time players, arcade fans, or a forgiving mix.
10. **Are there accessibility requirements beyond readable effects and clear
    damage feedback?**
    - Examples: remappable controls, colorblind-safe indicators, reduced motion,
      screen shake toggle, audio-independent telegraphs.
11. **Are scores, leaderboards, saves, or run replays needed?**
    - Recommended default: local score and a simple end-of-run summary only.

## Suggested decision order

Resolve route generation and pacing before implementing the full level system.
Visual style, audio, accessibility, and score features can be refined after a
playable combat slice exists.

## Selected engine and alternatives considered

### Selected: Godot 4 + GDScript

- Selected for the initial project because it is free and open source, supports
  straightforward desktop exporting, and fits the project's small 2D/2.5D scope.
- Strong 2D workflow while still supporting 3D scenes, lighting, particles,
  shaders, and a 2.5D presentation.
- GDScript keeps iteration fast for a small game and is approachable for
  OpenSpec-driven incremental work. It is the project's implementation language;
  C# is not planned for initial development.
- Lower ecosystem and high-end rendering depth than Unity or Unreal, which is
  unlikely to matter for the planned scope.

### Unity 6 + C#

- Strongest middle ground if the anime-inspired presentation will rely on
  3D models, post-processing, shaders, or third-party assets.
- Mature desktop tooling and a large asset ecosystem.
- More project and licensing complexity than needed for a small game; requires
  deliberate dependency and package management.

### Unreal Engine 5 + Blueprints/C++

- Best fit for high-end 3D visuals, lighting, and cinematic presentation.
- Disproportionately complex and heavy for a short-session top-down arcade game.
- Recommended only if the visual target is intended to be a major technical
  showcase rather than a compact game.

### Defold + Lua

- Lightweight, fast, and well suited to a 2D desktop arcade game.
- Less convenient than Godot or Unity for a 3D/3D-esque rendering pipeline and
  anime-style 3D effects.

### Custom framework, such as Bevy + Rust

- Maximum control and strong long-term engineering potential.
- Requires building or selecting more tooling for editor workflows, content,
  UI, and production iteration; not recommended for the first version.

### Other options considered, not selected

Unity 6 with C# was considered for its larger 3D asset ecosystem and more
advanced 3D tooling. Unreal Engine 5, Defold, and custom frameworks such as Bevy
were also considered. They are not selected for the initial project. Revisit
the engine decision only if a concrete requirement cannot be met well in Godot.

The first OpenSpec implementation should still validate the selected stack with
a tiny desktop prototype: one bounded arena, keyboard movement, mouse aiming,
and one placeholder ship. This validates the technical setup and M1 performance;
it is not an open engine-selection decision.
