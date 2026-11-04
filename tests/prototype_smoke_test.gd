extends SceneTree

const MainScene = preload("res://scenes/main.tscn")
const ProjectileScene = preload("res://scenes/projectile.tscn")
const AsteroidScene = preload("res://scenes/asteroid.tscn")

var failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game = MainScene.instantiate()
	root.add_child(game)
	current_scene = game
	await process_frame
	await physics_frame
	if DisplayServer.get_name() != "headless":
		var performance_start := Time.get_ticks_msec()
		const PERFORMANCE_SAMPLE_FRAMES: int = 120
		for frame in range(PERFORMANCE_SAMPLE_FRAMES):
			await process_frame
		var sample_duration := maxi(1, Time.get_ticks_msec() - performance_start)
		var measured_fps := int(float(PERFORMANCE_SAMPLE_FRAMES) * 1000.0 / float(sample_duration))
		print("Desktop smoke-test average FPS at 1080p output: %d" % measured_fps)
		_check(measured_fps >= 30, "1080p-output desktop encounter maintains at least 30 FPS")
	_check(game.phase == "active", "game starts in the active encounter")

	var arena: CombatArena = game.arena
	var player: PlayerShip = arena.player
	var hostile: HostileShip = arena.hostile
	var hostile_fired := [false]
	hostile.fire_requested.connect(func(_origin: Vector2, _direction: Vector2) -> void: hostile_fired[0] = true)
	var start_position := player.global_position
	Input.action_press("move_up")
	for frame in range(12):
		await physics_frame
	Input.action_release("move_up")
	_check(player.global_position.y < start_position.y, "keyboard input moves the ship")

	player.global_position = Vector2(640.0, 654.0)
	Input.action_press("move_down")
	await physics_frame
	Input.action_release("move_down")
	_check(player.global_position.y <= 654.1, "ship is clamped to the arena boundary")

	var mouse_motion := InputEventMouseMotion.new()
	mouse_motion.position = Vector2(930.0, 370.0)
	mouse_motion.global_position = mouse_motion.position
	player.aim_at(mouse_motion.position)
	var expected_angle := (mouse_motion.position - player.global_position).angle() + PI / 2.0
	_check(absf(angle_difference(player.rotation, expected_angle)) < 0.1, "mouse position independently controls ship aim")

	Input.action_press("fire_primary")
	await physics_frame
	Input.action_release("fire_primary")
	_check(_count_projectiles(arena) > 0, "primary-fire input spawns a projectile")
	_check(not _has_physical_projectile(), "projectiles remain outside the physical-body system")
	_check(game.hud.get_child_count() > 0, "HUD with discoverable controls is present")
	var capture_path := OS.get_environment("SPACE_FIGHTER_CAPTURE")
	if not capture_path.is_empty():
		var captured_frame := game.get_viewport().get_texture().get_image()
		var capture_error := captured_frame.save_png(capture_path)
		_check(capture_error == OK, "active combat frame can be captured for visual review")

	var asteroid: Area2D = arena.get_node("AsteroidLeft")
	var asteroid_destroyed := [false]
	asteroid.destroyed.connect(func() -> void: asteroid_destroyed[0] = true)
	(asteroid as AsteroidHazard).physics_body.velocity = Vector2.ZERO
	var direction := (asteroid.global_position - Vector2(asteroid.global_position.x, asteroid.global_position.y - 80.0)).normalized()
	var origin := asteroid.global_position - direction * 80.0
	for shot in range(3):
		var projectile: CombatProjectile = ProjectileScene.instantiate() as CombatProjectile
		projectile.configure(origin, direction, false)
		arena.add_child(projectile)
	for frame in range(24):
		await physics_frame
	_check(asteroid_destroyed[0], "player projectiles destroy a destructible asteroid")

	for frame in range(75):
		await physics_frame
	_check(hostile_fired[0], "hostile ship launches a visible hostile projectile")
	_check(player.health < player.MAX_HEALTH, "hostile fire can damage player survivability")

	hostile.take_damage(99)
	await process_frame
	_check(game.phase == "complete", "destroying the hostile ship completes the encounter")
	_check(game.hud.outcome_overlay.visible, "completion state is presented")
	game.call("_restart_encounter")
	await process_frame
	_check(game.phase == "active" and game.arena.hostile.health == HostileShip.MAX_HEALTH, "restart restores the encounter")

	player = game.arena.player
	for hit in range(player.MAX_HEALTH):
		player.damage_cooldown = 0.0
		player.take_damage(1)
	_check(game.phase == "defeated", "depleted player survivability ends the encounter")
	_check(game.hud.outcome_overlay.visible, "defeat state is presented")
	game.call("_restart_encounter")
	await process_frame
	_check(game.phase == "active" and game.arena.player.health == PlayerShip.MAX_HEALTH, "restart also restores player survivability after defeat")
	_test_asteroid_drift()
	var right_asteroid := game.arena.get_node("AsteroidRight") as AsteroidHazard
	_test_physical_collision(game.arena.player, right_asteroid)
	_test_physical_pair(game.arena.player, game.arena.hostile)
	_test_physical_pair(game.arena.hostile, right_asteroid)

	if failures == 0:
		print("Prototype smoke test passed: movement, aim, fire, bounds, asteroid drift and collisions, enemy fire, damage, outcomes, and restart.")
	else:
		printerr("Prototype smoke test failed with %d failure(s)." % failures)
	quit(1 if failures > 0 else 0)


func _count_projectiles(arena: CombatArena) -> int:
	var count := 0
	for child in arena.get_children():
		if child is CombatProjectile:
			count += 1
	return count


func _has_physical_projectile() -> bool:
	for entity in get_nodes_in_group("physical_body"):
		if entity is CombatProjectile:
			return true
	return false


func _test_asteroid_drift() -> void:
	var first := AsteroidScene.instantiate() as AsteroidHazard
	first.drift_seed = 7341
	root.add_child(first)
	var first_velocity: Vector2 = first.physics_body.velocity
	var second := AsteroidScene.instantiate() as AsteroidHazard
	second.drift_seed = 7341
	root.add_child(second)
	var second_velocity: Vector2 = second.physics_body.velocity
	_check(
		first_velocity.length() >= AsteroidHazard.MIN_DRIFT_SPEED
		and first_velocity.length() <= AsteroidHazard.MAX_DRIFT_SPEED,
		"asteroid initial drift stays within configured speed limits"
	)
	_check(first_velocity.length() > 0.0, "asteroid receives a nonzero initial trajectory")
	_check(first_velocity.is_equal_approx(second_velocity), "asteroid drift can be reproduced with a deterministic seed")
	first.free()
	second.free()


func _test_physical_collision(player: PlayerShip, asteroid: AsteroidHazard) -> void:
	var original_player_position: Vector2 = player.global_position
	var original_asteroid_position: Vector2 = asteroid.global_position
	var original_player_velocity: Vector2 = player.velocity
	var original_asteroid_velocity: Vector2 = asteroid.physics_body.velocity
	var original_player_health: int = player.health
	var original_asteroid_health: int = asteroid.health
	var original_damage_cooldown: float = player.damage_cooldown
	var contacts: Dictionary = {}
	var bodies: Array[ArcadePhysicsBody] = [player.physics_body, asteroid.physics_body]

	player.damage_cooldown = 0.0
	player.global_position = Vector2(400.0, 400.0)
	asteroid.global_position = Vector2(438.0, 400.0)
	player.velocity = Vector2(180.0, 0.0)
	asteroid.physics_body.velocity = Vector2(-10.0, 0.0)
	var player_health_before_impact: int = player.health
	var asteroid_health_before_impact: int = asteroid.health
	ArcadePhysics.step(bodies, 0.0, CombatArena.ARENA_RECT, contacts)
	_check(player.velocity.x < 180.0, "collision changes the player ship's trajectory")
	_check(asteroid.physics_body.velocity.x > -10.0, "collision transfers momentum to the other body")
	_check(player.health < player_health_before_impact, "hard impact damages the player ship")
	_check(asteroid.health < asteroid_health_before_impact, "hard impact damages the asteroid")

	var player_health_after_impact: int = player.health
	var asteroid_health_after_impact: int = asteroid.health
	player.global_position = Vector2(400.0, 400.0)
	asteroid.global_position = Vector2(438.0, 400.0)
	ArcadePhysics.step(bodies, 0.0, CombatArena.ARENA_RECT, contacts)
	_check(
		player.health == player_health_after_impact and asteroid.health == asteroid_health_after_impact,
		"sustained contact does not repeatedly apply impact damage"
	)
	_check(
		player.global_position.distance_to(asteroid.global_position) >= player.physics_body.radius + asteroid.physics_body.radius,
		"overlapping physical bodies are separated"
	)

	player.global_position = Vector2(60.0, 400.0)
	player.velocity = Vector2(-100.0, 0.0)
	var boundary_bodies: Array[ArcadePhysicsBody] = [player.physics_body]
	var boundary_contacts: Dictionary = {}
	ArcadePhysics.step(boundary_bodies, 0.0, CombatArena.ARENA_RECT, boundary_contacts)
	_check(player.global_position.x >= CombatArena.ARENA_RECT.position.x + player.physics_body.radius, "arena boundary prevents physical bodies escaping")
	_check(player.velocity.x > 0.0, "arena boundary redirects velocity into the arena")

	player.global_position = original_player_position
	asteroid.global_position = original_asteroid_position
	player.velocity = original_player_velocity
	asteroid.physics_body.velocity = original_asteroid_velocity
	player.health = original_player_health
	asteroid.health = original_asteroid_health
	player.damage_cooldown = original_damage_cooldown
	player.health_changed.emit(player.health, PlayerShip.MAX_HEALTH)


func _test_physical_pair(first_owner: Node2D, second_owner: Node2D) -> void:
	var first_body: ArcadePhysicsBody = first_owner.call("get_physics_body")
	var second_body: ArcadePhysicsBody = second_owner.call("get_physics_body")
	var first_original_position: Vector2 = first_owner.global_position
	var second_original_position: Vector2 = second_owner.global_position
	var first_original_velocity: Vector2 = first_body.velocity
	var second_original_velocity: Vector2 = second_body.velocity
	var first_original_health: int = int(first_owner.get("health"))
	var second_original_health: int = int(second_owner.get("health"))
	var first_original_cooldown: float = 0.0
	var second_original_cooldown: float = 0.0
	if first_owner is PlayerShip:
		first_original_cooldown = first_owner.damage_cooldown
		first_owner.damage_cooldown = 0.0
	if second_owner is PlayerShip:
		second_original_cooldown = second_owner.damage_cooldown
		second_owner.damage_cooldown = 0.0

	first_owner.global_position = Vector2(500.0, 400.0)
	second_owner.global_position = Vector2(538.0, 400.0)
	first_body.velocity = Vector2(180.0, 0.0)
	second_body.velocity = Vector2(-10.0, 0.0)
	var contacts: Dictionary = {}
	var bodies: Array[ArcadePhysicsBody] = [first_body, second_body]
	ArcadePhysics.step(bodies, 0.0, CombatArena.ARENA_RECT, contacts)
	_check(first_body.velocity.x < 180.0, "ship collision responds to a physical impulse")
	_check(second_body.velocity.x > -10.0, "ship collision transfers momentum to its partner")
	_check(int(first_owner.get("health")) < first_original_health, "first ship receives impact damage")
	_check(int(second_owner.get("health")) < second_original_health, "second ship receives impact damage")

	first_owner.global_position = first_original_position
	second_owner.global_position = second_original_position
	first_body.velocity = first_original_velocity
	second_body.velocity = second_original_velocity
	first_owner.set("health", first_original_health)
	second_owner.set("health", second_original_health)
	if first_owner is PlayerShip:
		first_owner.damage_cooldown = first_original_cooldown
		first_owner.health_changed.emit(first_owner.health, PlayerShip.MAX_HEALTH)
	if second_owner is PlayerShip:
		second_owner.damage_cooldown = second_original_cooldown
		second_owner.health_changed.emit(second_owner.health, PlayerShip.MAX_HEALTH)


func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		failures += 1
		printerr("FAIL: %s" % description)
