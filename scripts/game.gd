extends Node2D

const ArenaScene = preload("res://scenes/arena.tscn")
const ProjectileScene = preload("res://scenes/projectile.tscn")

var arena: CombatArena
var hud: PrototypeHUD
var phase: String = "active"
var remaining_enemies: int = 0


func _ready() -> void:
	hud = PrototypeHUD.new()
	add_child(hud)
	hud.restart_requested.connect(_restart_encounter)
	_start_encounter()


func _unhandled_input(event: InputEvent) -> void:
	if phase != "active" and event.is_action_pressed("restart_encounter"):
		_restart_encounter()


func _start_encounter() -> void:
	phase = "active"
	arena = ArenaScene.instantiate() as CombatArena
	add_child(arena)
	var player: PlayerShip = arena.player
	var hostile: HostileShip = arena.hostile
	remaining_enemies = 1
	hostile.set_target(player)
	player.fire_requested.connect(_on_player_fire_requested)
	player.health_changed.connect(_on_player_health_changed)
	player.destroyed.connect(_on_player_destroyed)
	hostile.fire_requested.connect(_on_hostile_fire_requested)
	hostile.destroyed.connect(_on_hostile_destroyed)
	hud.set_health(player.health, player.MAX_HEALTH)
	hud.set_remaining_enemies(remaining_enemies)
	hud.outcome_overlay.visible = false


func _on_player_fire_requested(origin: Vector2, direction: Vector2) -> void:
	_spawn_projectile(origin, direction, false)


func _on_hostile_fire_requested(origin: Vector2, direction: Vector2) -> void:
	_spawn_projectile(origin, direction, true)


func _spawn_projectile(origin: Vector2, direction: Vector2, hostile_shot: bool) -> void:
	if phase != "active":
		return
	var projectile: CombatProjectile = ProjectileScene.instantiate() as CombatProjectile
	projectile.configure(origin, direction, hostile_shot)
	arena.add_child(projectile)


func _on_player_health_changed(current: int, maximum: int) -> void:
	hud.set_health(current, maximum)


func _on_player_destroyed() -> void:
	_finish_encounter(false)


func _on_hostile_destroyed() -> void:
	remaining_enemies = maxi(0, remaining_enemies - 1)
	hud.set_remaining_enemies(remaining_enemies)
	if remaining_enemies == 0:
		_finish_encounter(true)


func _finish_encounter(victory: bool) -> void:
	if phase != "active":
		return
	phase = "complete" if victory else "defeated"
	arena.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	hud.show_outcome(victory)


func _restart_encounter() -> void:
	if phase == "active":
		return
	arena.queue_free()
	_start_encounter()
