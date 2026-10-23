extends SceneTree

const MainScene = preload("res://scenes/main.tscn")
const ProjectileScene = preload("res://scenes/projectile.tscn")

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
	_check(game.hud.get_child_count() > 0, "HUD with discoverable controls is present")
	var capture_path := OS.get_environment("SPACE_FIGHTER_CAPTURE")
	if not capture_path.is_empty():
		var captured_frame := game.get_viewport().get_texture().get_image()
		var capture_error := captured_frame.save_png(capture_path)
		_check(capture_error == OK, "active combat frame can be captured for visual review")

	var asteroid: Area2D = arena.get_node("AsteroidLeft")
	var asteroid_destroyed := [false]
	asteroid.destroyed.connect(func() -> void: asteroid_destroyed[0] = true)
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

	if failures == 0:
		print("Prototype smoke test passed: movement, aim, fire, bounds, asteroid, enemy fire, damage, outcomes, and restart.")
	else:
		printerr("Prototype smoke test failed with %d failure(s)." % failures)
	quit(1 if failures > 0 else 0)


func _count_projectiles(arena: CombatArena) -> int:
	var count := 0
	for child in arena.get_children():
		if child is CombatProjectile:
			count += 1
	return count


func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		failures += 1
		printerr("FAIL: %s" % description)
