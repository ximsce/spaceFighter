extends Area2D

signal destroyed

const ImpactEffect = preload("res://scripts/impact_effect.gd")
const MAX_HEALTH: int = 3

var health: int = MAX_HEALTH
var hit_flash: float = 0.0
var is_destroyed: bool = false
var rock_points := PackedVector2Array([
	Vector2(-23, -12), Vector2(-12, -25), Vector2(7, -22), Vector2(24, -7),
	Vector2(20, 13), Vector2(5, 24), Vector2(-15, 21), Vector2(-25, 4)
])


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 | 2
	add_to_group("asteroid_hazard")


func _process(delta: float) -> void:
	hit_flash = maxf(0.0, hit_flash - delta)
	rotation += delta * 0.08
	queue_redraw()


func take_damage(amount: int) -> void:
	if is_destroyed:
		return
	health = maxi(0, health - amount)
	hit_flash = 0.16
	var effect := ImpactEffect.new()
	effect.configure(global_position, Color(1.0, 0.66, 0.35), 0.65)
	get_tree().current_scene.add_child(effect)
	if health <= 0:
		is_destroyed = true
		destroyed.emit()
		var burst := ImpactEffect.new()
		burst.configure(global_position, Color(1.0, 0.48, 0.2), 1.35)
		get_tree().current_scene.add_child(burst)
		queue_free()


func _draw() -> void:
	var rock_color := Color(0.40, 0.47, 0.62)
	if hit_flash > 0.0:
		rock_color = Color(1.0, 0.8, 0.58)
	draw_colored_polygon(rock_points, rock_color)
	draw_polyline(PackedVector2Array([
		Vector2(-23, -12), Vector2(-12, -25), Vector2(7, -22), Vector2(24, -7),
		Vector2(20, 13), Vector2(5, 24), Vector2(-15, 21), Vector2(-25, 4), Vector2(-23, -12)
	]), Color(0.73, 0.83, 1.0), 2.0, true)
	draw_line(Vector2(-10, -11), Vector2(1, -4), Color(0.20, 0.27, 0.42), 2.0, true)
	draw_line(Vector2(1, -4), Vector2(-4, 9), Color(0.20, 0.27, 0.42), 2.0, true)
	if health <= 1:
		draw_line(Vector2(7, -15), Vector2(4, -4), Color(1.0, 0.51, 0.28), 2.0, true)
