extends Area2D
class_name CombatProjectile

const ImpactEffect = preload("res://scripts/impact_effect.gd")
const PLAYER_SHOT_LAYER: int = 2
const ENEMY_SHOT_LAYER: int = 16
const ASTEROID_LAYER: int = 4
const ENEMY_LAYER: int = 8
const PLAYER_LAYER: int = 1

var direction: Vector2 = Vector2.UP
var is_hostile: bool = false
var damage: int = 1
var speed: float = 760.0
var lifetime: float = 1.45
var age: float = 0.0


func configure(at: Vector2, shot_direction: Vector2, hostile: bool) -> void:
	global_position = at
	direction = shot_direction.normalized()
	is_hostile = hostile


func _ready() -> void:
	if is_hostile:
		collision_layer = ENEMY_SHOT_LAYER
		collision_mask = PLAYER_LAYER
	else:
		collision_layer = PLAYER_SHOT_LAYER
		collision_mask = ASTEROID_LAYER | ENEMY_LAYER
	area_entered.connect(_on_area_entered)
	rotation = direction.angle() + PI / 2.0


func _physics_process(delta: float) -> void:
	age += delta
	global_position += direction * speed * delta
	if age >= lifetime:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
	var effect := ImpactEffect.new()
	effect.configure(global_position, Color(1.0, 0.48, 0.24) if is_hostile else Color(0.26, 0.88, 1.0), 0.55)
	get_tree().current_scene.add_child(effect)
	queue_free()


func _draw() -> void:
	var tint := Color(1.0, 0.45, 0.22) if is_hostile else Color(0.36, 0.94, 1.0)
	draw_line(Vector2(0, 11), Vector2(0, -8), tint, 4.0, true)
	draw_circle(Vector2.ZERO, 3.5, Color.WHITE)
