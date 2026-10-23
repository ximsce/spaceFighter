# Space Fighter

A small, replayable 2D space-combat game designed for **5–15 minute runs**.

The player pilots a ship through increasingly dangerous waves of asteroids,
debris, and hostile ships. The ship can fire, take damage behind a shield,
and earn temporary upgrades during a run.

## Current status

This repository is in the context and discovery phase. The engine and language
are selected: **Godot 4 with GDScript**. Remaining open product and technical
decisions are tracked in [`docs/open-questions.md`](docs/open-questions.md).

## Source of truth

- [`openspec/config.yaml`](openspec/config.yaml) — project-wide guidance for
  OpenSpec changes.
- [`docs/game-design.md`](docs/game-design.md) — provisional game design,
  scope, vocabulary, and gameplay boundaries.
- [`docs/open-questions.md`](docs/open-questions.md) — decisions needed before
  implementation details are made permanent.

## Development approach

Nearly all implementation should happen through OpenSpec changes. Each change
should be small enough to implement and play-test independently, state its
player-facing behavior, and avoid introducing systems that are not needed for
the short-run arcade experience.
