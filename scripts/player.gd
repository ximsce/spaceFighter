extends Area2D
class_name PlayerShip

signal health_changed(current: int, maximum: int)
signal destroyed
signal fire_requested(origin: Vector2, direction: Vector2)

const ImpactEffect = preload("res://scripts/impact_effect.gd")
const MAX_HEALTH: int = 6
const MOVE_SPEED: float = 300.0
const ACCELERATION: float = 1500.0
const FIRE_INTERVAL: float = 0.17
const PHYSICS_MASS: float = 2.8
const PHYSICS_RADIUS: float = 22.0
const PHYSICS_MAX_SPEED: float = 430.0
const PHYSICS_RESTITUTION: float = 0.2

var health: int = MAX_HEALTH
var physics_body: ArcadePhysicsBody
var velocity: Vector2:
	get:
		return physics_body.velocity if physics_body != null else Vector2.ZERO
	set(value):
		if physics_body != null:
			physics_body.velocity = value
var fire_cooldown: float = 0.0
var damage_cooldown: float = 0.0
var hit_flash: float = 0.0
var is_destroyed: bool = false


func _ready() -> void:
	physics_body = ArcadePhysicsBody.new(
		self,
		PHYSICS_MASS,
		PHYSICS_RADIUS,
		PHYSICS_MAX_SPEED,
		PHYSICS_RESTITUTION,
		ACCELERATION
	)
	add_to_group("physical_body")
	collision_layer = 1
	collision_mask = 4 | 8
	add_to_group("player_ship")
	health_changed.emit(health, MAX_HEALTH)


func _physics_process(delta: float) -> void:
	if is_destroyed:
		return
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	damage_cooldown = maxf(0.0, damage_cooldown - delta)
	hit_flash = maxf(0.0, hit_flash - delta)
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	physics_body.movement_target = input_direction * MOVE_SPEED
	var aim_direction := get_global_mouse_position() - global_position
	aim_at(get_global_mouse_position())
	if Input.is_action_pressed("fire_primary") and fire_cooldown <= 0.0:
		var shot_direction := aim_direction.normalized()
		if shot_direction.length_squared() > 0.5:
			fire_requested.emit(global_position + shot_direction * 27.0, shot_direction)
			fire_cooldown = FIRE_INTERVAL
	queue_redraw()


func aim_at(world_position: Vector2) -> void:
	var aim_direction := world_position - global_position
	if aim_direction.length_squared() > 4.0:
		rotation = aim_direction.angle() + PI / 2.0


func take_damage(amount: int) -> void:
	if is_destroyed or damage_cooldown > 0.0:
		return
	health = maxi(0, health - amount)
	damage_cooldown = 0.38
	hit_flash = 0.2
	health_changed.emit(health, MAX_HEALTH)
	_spawn_effect(global_position, Color(1.0, 0.36, 0.48), 1.0)
	if health <= 0:
		is_destroyed = true
		physics_body.enabled = false
		destroyed.emit()
		_spawn_effect(global_position, Color(1.0, 0.34, 0.55), 1.8)
		queue_free()


func get_physics_body() -> ArcadePhysicsBody:
	return physics_body


func take_impact_damage(amount: int) -> void:
	take_damage(amount)


func _spawn_effect(at: Vector2, tint: Color, strength: float) -> void:
	var effect := ImpactEffect.new()
	effect.configure(at, tint, strength)
	get_tree().current_scene.add_child(effect)


func _draw() -> void:
	var hull := Color(0.22, 0.88, 1.0)
	if hit_flash > 0.0 and int(hit_flash * 35.0) % 2 == 0:
		hull = Color.WHITE
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -25), Vector2(17, 12), Vector2(7, 8), Vector2(0, 15),
		Vector2(-7, 8), Vector2(-17, 12)
	]), hull)
	draw_polyline(PackedVector2Array([
		Vector2(0, -25), Vector2(17, 12), Vector2(7, 8), Vector2(0, 15),
		Vector2(-7, 8), Vector2(-17, 12), Vector2(0, -25)
	]), Color(0.78, 0.98, 1.0), 2.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -16), Vector2(5, 1), Vector2(0, 5), Vector2(-5, 1)
	]), Color(0.04, 0.16, 0.32))
	draw_line(Vector2(-6, 13), Vector2(-3, 20), Color(1.0, 0.54, 0.22), 3.0, true)
	draw_line(Vector2(6, 13), Vector2(3, 20), Color(1.0, 0.54, 0.22), 3.0, true)
