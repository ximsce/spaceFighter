extends Node2D
class_name CombatArena

const ARENA_RECT := Rect2(48.0, 88.0, 1184.0, 588.0)

@onready var player: PlayerShip = $Player
@onready var hostile: HostileShip = $HostileShip


func _ready() -> void:
	hostile.set_target(player)
	queue_redraw()


func _draw() -> void:
	draw_rect(ARENA_RECT, Color(0.035, 0.065, 0.13, 0.72), true)
	var rng := RandomNumberGenerator.new()
	rng.seed = 72411
	for index in range(96):
		var star := Vector2(rng.randf_range(0.0, 1280.0), rng.randf_range(0.0, 720.0))
		var radius := rng.randf_range(0.7, 1.7)
		draw_circle(star, radius, Color(0.44, 0.65, 0.9, rng.randf_range(0.12, 0.48)))

	for x in range(ARENA_RECT.position.x + 48.0, ARENA_RECT.end.x, 64.0):
		draw_line(Vector2(x, ARENA_RECT.position.y), Vector2(x, ARENA_RECT.end.y), Color(0.19, 0.34, 0.52, 0.13), 1.0)
	for y in range(ARENA_RECT.position.y + 48.0, ARENA_RECT.end.y, 64.0):
		draw_line(Vector2(ARENA_RECT.position.x, y), Vector2(ARENA_RECT.end.x, y), Color(0.19, 0.34, 0.52, 0.13), 1.0)
	draw_rect(ARENA_RECT, Color(0.22, 0.73, 0.92, 0.8), false, 2.0)
	for corner in [ARENA_RECT.position, Vector2(ARENA_RECT.end.x, ARENA_RECT.position.y), ARENA_RECT.end, Vector2(ARENA_RECT.position.x, ARENA_RECT.end.y)]:
		draw_circle(corner, 4.0, Color(0.35, 0.9, 1.0))
