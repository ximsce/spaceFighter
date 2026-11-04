extends RefCounted
class_name ArcadePhysics

const IMPACT_DAMAGE_THRESHOLD: float = 90.0
const IMPACT_SPEED_PER_DAMAGE: float = 110.0
const MAX_IMPACT_DAMAGE: int = 3
const POSITION_CORRECTION_SLOP: float = 0.01


static func step(
	bodies: Array[ArcadePhysicsBody],
	delta: float,
	arena_bounds: Rect2,
	active_contacts: Dictionary
) -> void:
	for body in bodies:
		if not _is_body_active(body):
			continue
		if delta > 0.0 and body.acceleration > 0.0:
			body.velocity = body.velocity.move_toward(body.movement_target, body.acceleration * delta)
		if body.max_speed > 0.0 and body.velocity.length_squared() > body.max_speed * body.max_speed:
			body.velocity = body.velocity.normalized() * body.max_speed
		if delta > 0.0:
			body.owner.global_position += body.velocity * delta
		_resolve_arena_bounds(body, arena_bounds)

	var current_contacts: Dictionary = {}
	for first_index in range(bodies.size()):
		var first := bodies[first_index]
		if not _is_body_active(first):
			continue
		for second_index in range(first_index + 1, bodies.size()):
			var second := bodies[second_index]
			if not _is_body_active(second):
				continue
			_resolve_pair(first, second, current_contacts, active_contacts)

	active_contacts.clear()
	active_contacts.merge(current_contacts)


static func _resolve_pair(
	first: ArcadePhysicsBody,
	second: ArcadePhysicsBody,
	current_contacts: Dictionary,
	active_contacts: Dictionary
) -> void:
	var offset: Vector2 = second.owner.global_position - first.owner.global_position
	var minimum_distance: float = first.radius + second.radius
	var distance_squared: float = offset.length_squared()
	if distance_squared >= minimum_distance * minimum_distance:
		return

	var distance: float = sqrt(distance_squared)
	var normal: Vector2 = offset / distance if distance > 0.001 else Vector2.RIGHT
	var pair_key := _contact_key(first, second)
	current_contacts[pair_key] = true

	var relative_velocity: Vector2 = second.velocity - first.velocity
	var closing_speed: float = maxf(0.0, -relative_velocity.dot(normal))
	if not active_contacts.has(pair_key) and closing_speed >= IMPACT_DAMAGE_THRESHOLD:
		var damage: int = mini(
			MAX_IMPACT_DAMAGE,
			1 + floori((closing_speed - IMPACT_DAMAGE_THRESHOLD) / IMPACT_SPEED_PER_DAMAGE)
		)
		first.owner.call("take_impact_damage", damage)
		second.owner.call("take_impact_damage", damage)

	var inverse_mass_sum: float = 1.0 / first.mass + 1.0 / second.mass
	if closing_speed > 0.0:
		var combined_restitution: float = (first.restitution + second.restitution) * 0.5
		var impulse_magnitude: float = (1.0 + combined_restitution) * closing_speed / inverse_mass_sum
		var impulse: Vector2 = normal * impulse_magnitude
		first.velocity -= impulse / first.mass
		second.velocity += impulse / second.mass

	var penetration: float = minimum_distance - distance
	var correction: Vector2 = normal * ((penetration + POSITION_CORRECTION_SLOP) / inverse_mass_sum)
	first.owner.global_position -= correction / first.mass
	second.owner.global_position += correction / second.mass


static func _resolve_arena_bounds(body: ArcadePhysicsBody, arena_bounds: Rect2) -> void:
	var position: Vector2 = body.owner.global_position
	var minimum_x: float = arena_bounds.position.x + body.radius
	var maximum_x: float = arena_bounds.end.x - body.radius
	var minimum_y: float = arena_bounds.position.y + body.radius
	var maximum_y: float = arena_bounds.end.y - body.radius

	if position.x < minimum_x:
		position.x = minimum_x
		if body.velocity.x < 0.0:
			body.velocity.x = -body.velocity.x * body.restitution
	elif position.x > maximum_x:
		position.x = maximum_x
		if body.velocity.x > 0.0:
			body.velocity.x = -body.velocity.x * body.restitution

	if position.y < minimum_y:
		position.y = minimum_y
		if body.velocity.y < 0.0:
			body.velocity.y = -body.velocity.y * body.restitution
	elif position.y > maximum_y:
		position.y = maximum_y
		if body.velocity.y > 0.0:
			body.velocity.y = -body.velocity.y * body.restitution

	body.owner.global_position = position


static func _contact_key(first: ArcadePhysicsBody, second: ArcadePhysicsBody) -> Vector2i:
	var first_id: int = first.owner.get_instance_id()
	var second_id: int = second.owner.get_instance_id()
	return Vector2i(mini(first_id, second_id), maxi(first_id, second_id))


static func _is_body_active(body: ArcadePhysicsBody) -> bool:
	return (
		body != null
		and body.enabled
		and is_instance_valid(body.owner)
		and not body.owner.is_queued_for_deletion()
	)
