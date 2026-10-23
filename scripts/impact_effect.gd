extends Node2D

var tint: Color = Color.WHITE
var strength: float = 1.0
var age: float = 0.0
const DURATION: float = 0.28


func configure(at: Vector2, effect_tint: Color, effect_strength: float = 1.0) -> void:
	global_position = at
	tint = effect_tint
	strength = effect_strength


func _process(delta: float) -> void:
	age += delta
	queue_redraw()
	if age >= DURATION:
		queue_free()


func _draw() -> void:
	var progress := clampf(age / DURATION, 0.0, 1.0)
	var alpha := 1.0 - progress
	var radius := lerpf(4.0, 24.0 * strength, progress)
	var color := Color(tint.r, tint.g, tint.b, alpha)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, color, maxf(1.0, 4.0 * (1.0 - progress)), true)
	for index in range(6):
		var angle := TAU * float(index) / 6.0 + age * 2.0
		var direction := Vector2.RIGHT.rotated(angle)
		draw_line(direction * radius * 0.35, direction * (radius + 7.0), color, 2.0, true)
