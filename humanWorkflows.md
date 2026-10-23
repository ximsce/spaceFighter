# Human Workflows

This document describes the recommended human-facing workflow for developing
Space Fighter with OpenSpec and OpenCode.

## Default OpenCode model

Use **`opencode-go/gpt-6-luna`** as the project’s default model.

Recommended variants:

- **`high`** — normal OpenSpec implementation work, gameplay code, and routine
  debugging.
- **`xhigh`** — architecture, major OpenSpec proposals, cross-system changes,
  performance investigations, and difficult debugging.
- **`max`** — exceptional use for especially complex design or refactoring
  problems where additional reasoning is worth the extra latency.

The model choice is independent of the game engine. It should help keep
OpenSpec artifacts, GDScript code, and project context aligned.

## Model selection by task

| Task | Recommended model and variant |
| --- | --- |
| Architecture and OpenSpec proposals | GPT-6 Luna `xhigh` |
| Major gameplay systems | GPT-6 Luna `high` or Kimi K3.1 Pro `high` |
| Debugging and performance work | GPT-6 Luna `xhigh` |
| Code review and repository review | Gemini 4 Argon Contributor `high` |
| Small routine changes and documentation | MiniMax M3.1 Flash `high` |

Use the default model consistently for related work so that design decisions
and implementation conventions remain coherent. Switch models deliberately
when seeking an independent review or when a faster model is sufficient.

## OpenSpec workflow

For each meaningful feature:

1. Start with an OpenSpec proposal describing player-facing behavior, scope,
   non-goals, and acceptance criteria.
2. Ask the model to inspect the existing context and relevant specifications
   before proposing implementation details.
3. Break the work into a small, playable change whenever possible.
4. Implement the change and manually play-test it.
5. Ask for a focused review of edge cases, performance, and consistency with
   `docs/game-design.md`.
6. Update shared context when the approved change alters the game model.

## Human responsibilities

The model should assist with exploration, specification, implementation, and
review, but a human should make the final decisions about:

- changes to the selected engine or language;
- game feel, difficulty, and pacing;
- art direction and asset licensing;
- scope changes and non-goals;
- whether a change is fun and readable during play-testing;
- acceptance of generated code and OpenSpec artifacts.

## Current engine context

The project has selected **Godot 4 with GDScript**. Use Godot's built-in scene,
node, resource, and signal patterns. Unity 6 with C# and other options were
considered, but are not current plans; reconsider only if a concrete project
requirement demonstrates a limitation that Godot cannot address appropriately.

Model availability, names, and variants can change in OpenCode Go. Verify the
current catalog before standardizing a new workflow or documenting a permanent
configuration.
