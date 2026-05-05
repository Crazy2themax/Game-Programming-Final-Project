extends CanvasLayer


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


func _exit_tree() -> void:
	var localization = _localization()
	if localization != null and localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.disconnect(_on_language_changed)


func _on_language_changed(_language_code: String) -> void:
	_update_controls_text()


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