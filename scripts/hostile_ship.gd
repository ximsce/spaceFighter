extends Area2D
class_name HostileShip

signal destroyed
signal fire_requested(origin: Vector2, direction: Vector2)

const ImpactEffect = preload("res://scripts/impact_effect.gd")
const MAX_HEALTH: int = 6
const ATTACK_INTERVAL: float = 1.85
const TELEGRAPH_TIME: float = 0.62

var health: int = MAX_HEALTH
var target: Area2D
var base_position: Vector2
var elapsed: float = 0.0
var attack_timer: float = 0.9
var hit_flash: float = 0.0
var is_destroyed: bool = false
var telegraphing: bool = false


func _ready() -> void:
	collision_layer = 8
	collision_mask = 1 | 2
	add_to_group("hostile_ship")
	base_position = position


func set_target(player: Area2D) -> void:
	target = player


func _process(delta: float) -> void:
	if is_destroyed:
		return
	elapsed += delta
	hit_flash = maxf(0.0, hit_flash - delta)
	position.x = base_position.x + sin(elapsed * 1.15) * 34.0
	attack_timer -= delta
	telegraphing = attack_timer <= TELEGRAPH_TIME
	if attack_timer <= 0.0 and is_instance_valid(target):
		var shot_direction := (target.global_position - global_position).normalized()
		fire_requested.emit(global_position + shot_direction * 25.0, shot_direction)
		attack_timer = ATTACK_INTERVAL
		telegraphing = false
	queue_redraw()


func take_damage(amount: int) -> void:
	if is_destroyed:
		return
	health = maxi(0, health - amount)
	hit_flash = 0.18
	var effect := ImpactEffect.new()
	effect.configure(global_position, Color(1.0, 0.34, 0.73), 0.7)
	get_tree().current_scene.add_child(effect)
	if health <= 0:
		is_destroyed = true
		destroyed.emit()
		var burst := ImpactEffect.new()
		burst.configure(global_position, Color(1.0, 0.34, 0.73), 1.8)
		get_tree().current_scene.add_child(burst)
		queue_free()


func _draw() -> void:
	if telegraphing and is_instance_valid(target):
		var local_target := to_local(target.global_position)
		draw_line(Vector2.ZERO, local_target, Color(1.0, 0.38, 0.32, 0.5), 1.5, true)
		draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 32, Color(1.0, 0.4, 0.35, 0.55), 2.0, true)
	var hull := Color(1.0, 0.30, 0.63)
	if hit_flash > 0.0 and int(hit_flash * 35.0) % 2 == 0:
		hull = Color.WHITE
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 24), Vector2(20, -11), Vector2(8, -7), Vector2(0, -16),
		Vector2(-8, -7), Vector2(-20, -11)
	]), hull)
	draw_polyline(PackedVector2Array([
		Vector2(0, 24), Vector2(20, -11), Vector2(8, -7), Vector2(0, -16),
		Vector2(-8, -7), Vector2(-20, -11), Vector2(0, 24)
	]), Color(1.0, 0.81, 0.93), 2.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 17), Vector2(5, 1), Vector2(0, -2), Vector2(-5, 1)
	]), Color(0.27, 0.06, 0.20))
	draw_circle(Vector2(0, 15), 3.0, Color(1.0, 0.6, 0.18))
