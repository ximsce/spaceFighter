extends CanvasLayer
class_name PrototypeHUD

signal restart_requested

var health_label: Label
var objective_label: Label
var outcome_overlay: ColorRect
var outcome_title: Label


func _ready() -> void:
	layer = 10
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var top_band := ColorRect.new()
	top_band.color = Color(0.015, 0.025, 0.065, 0.94)
	top_band.anchor_right = 1.0
	top_band.offset_bottom = 72.0
	top_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top_band)

	var title := _make_label("SPACE FIGHTER  /  COMBAT TEST", 20, Color(0.43, 0.9, 1.0))
	title.position = Vector2(22, 10)
	title.size = Vector2(520, 28)
	root.add_child(title)

	health_label = _make_label("HULL  6 / 6", 18, Color(0.77, 0.95, 1.0))
	health_label.position = Vector2(22, 39)
	health_label.size = Vector2(250, 25)
	root.add_child(health_label)

	objective_label = _make_label("HOSTILE CONTACTS  1", 18, Color(1.0, 0.53, 0.77))
	objective_label.position = Vector2(900, 22)
	objective_label.size = Vector2(350, 30)
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(objective_label)

	var objective_hint := _make_label("Destroy the hostile fighter. Asteroids can be destroyed or avoided.", 15, Color(0.69, 0.79, 0.92))
	objective_hint.position = Vector2(64, 94)
	objective_hint.size = Vector2(800, 24)
	root.add_child(objective_hint)

	var controls := _make_label("WASD / ARROWS  MOVE     |     MOUSE  AIM     |     HOLD LEFT MOUSE  FIRE", 15, Color(0.65, 0.82, 0.95))
	controls.anchor_top = 1.0
	controls.anchor_bottom = 1.0
	controls.offset_left = 22.0
	controls.offset_top = -40.0
	controls.offset_right = 850.0
	controls.offset_bottom = -12.0
	root.add_child(controls)

	outcome_overlay = ColorRect.new()
	outcome_overlay.color = Color(0.012, 0.02, 0.055, 0.86)
	outcome_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outcome_overlay.visible = false
	outcome_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(outcome_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outcome_overlay.add_child(center)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(layout)

	outcome_title = _make_label("", 42, Color(0.48, 0.94, 1.0))
	outcome_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(outcome_title)

	var outcome_hint := _make_label("Press R or choose below to run the encounter again.", 17, Color(0.77, 0.84, 0.95))
	outcome_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(outcome_hint)

	var restart_button := Button.new()
	restart_button.text = "RESTART ENCOUNTER"
	restart_button.custom_minimum_size = Vector2(250, 48)
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	layout.add_child(restart_button)


func set_health(current: int, maximum: int) -> void:
	if not is_instance_valid(health_label):
		return
	health_label.text = "HULL  %d / %d" % [current, maximum]
	health_label.add_theme_color_override("font_color", Color(1.0, 0.38, 0.48) if current <= 2 else Color(0.77, 0.95, 1.0))


func set_remaining_enemies(remaining: int) -> void:
	if is_instance_valid(objective_label):
		objective_label.text = "HOSTILE CONTACTS  %02d" % remaining


func show_outcome(victory: bool) -> void:
	outcome_title.text = "ENCOUNTER CLEARED" if victory else "SHIP LOST"
	outcome_title.add_theme_color_override("font_color", Color(0.43, 0.94, 1.0) if victory else Color(1.0, 0.38, 0.53))
	outcome_overlay.visible = true


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
