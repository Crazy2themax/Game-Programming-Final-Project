extends CanvasLayer


@export var level_exit_x := 1100.0
@export var win_scene_path := "res://Assets/scenes/in-middle-level-win.tscn"

var _exit_triggered := false

@onready var controls_layer: CanvasLayer = $CanvasLayer
@onready var controls_label: Label = $CanvasLayer/Label


func _localization():
	return get_node_or_null("/root/Localization")


func _ready() -> void:
	var localization = _localization()
	if localization != null:
		localization.language_changed.connect(_on_language_changed)
	_update_controls_text()
	_hide_controls_after_delay()
	set_process(true)


func _exit_tree() -> void:
	var localization = _localization()
	if localization != null and localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.disconnect(_on_language_changed)


func _on_language_changed(_language_code: String) -> void:
	_update_controls_text()


func _process(_delta: float) -> void:
	if _exit_triggered:
		return
	if win_scene_path.is_empty():
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	if player.global_position.x >= level_exit_x:
		_exit_triggered = true
		get_tree().change_scene_to_file(win_scene_path)


func _update_controls_text() -> void:
	var localization = _localization()
	if localization == null:
		return

	controls_label.text = "%s: %s\n%s: %s\n%s: %s\n%s: %s" % [
		localization.get_action_display_name("move_left"),
		localization.tr_key("tutorial.move_left", "Move Left"),
		localization.get_action_display_name("move_right"),
		localization.tr_key("tutorial.move_right", "Move Right"),
		localization.get_action_display_name("jump"),
		localization.tr_key("tutorial.jump", "Jump"),
		localization.get_action_display_name("attack_1"),
		localization.tr_key("tutorial.attack", "Attack")
	]


func _hide_controls_after_delay() -> void:
	await get_tree().create_timer(5.0).timeout
	controls_layer.hide()