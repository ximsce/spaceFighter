extends RefCounted
class_name ArcadePhysicsBody

var owner: Node2D
var velocity: Vector2 = Vector2.ZERO
var movement_target: Vector2 = Vector2.ZERO
var acceleration: float = 0.0
var coast_deceleration: float = 0.0
var mass: float = 1.0
var radius: float = 20.0
var max_speed: float = 400.0
var restitution: float = 0.25
var enabled: bool = true


func _init(
	body_owner: Node2D,
	body_mass: float,
	body_radius: float,
	body_max_speed: float,
	body_restitution: float,
	body_acceleration: float = 0.0,
	body_coast_deceleration: float = -1.0
) -> void:
	owner = body_owner
	mass = maxf(0.01, body_mass)
	radius = maxf(1.0, body_radius)
	max_speed = maxf(0.0, body_max_speed)
	restitution = clampf(body_restitution, 0.0, 1.0)
	acceleration = maxf(0.0, body_acceleration)
	coast_deceleration = (
		acceleration if body_coast_deceleration < 0.0 else maxf(0.0, body_coast_deceleration)
	)
