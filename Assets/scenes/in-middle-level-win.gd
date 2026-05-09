extends Control

const LEVEL_2_PATH := "res://Assets/scenes/level_2.tscn"
const FINAL_LEVEL_PATH := "res://Assets/scenes/final-level.tscn"

var _next_scene_path := LEVEL_2_PATH

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var body_label: Label = $CenterContainer/VBoxContainer/BodyLabel
@onready var next_label: Label = $CenterContainer/VBoxContainer/NextQuestLabel
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton

func _localization() -> Node:
	return get_node_or_null("/root/Localization")

func _ready() -> void:
	var localization := _localization()
	if localization != null:
		localization.language_changed.connect(_on_language_changed)
	_update_texts()
	start_button.pressed.connect(_on_start_pressed)

func _exit_tree() -> void:
	var localization := _localization()
	if localization != null and localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.disconnect(_on_language_changed)

func _on_language_changed(_language_code: String) -> void:
	_update_texts()

func _update_texts() -> void:
	var localization := _localization()
	var completed_level := 1
	if GameSession != null and GameSession.has_method("get_highest_level_reached"):
		completed_level = GameSession.get_highest_level_reached()

	if completed_level <= 1:
		_next_scene_path = LEVEL_2_PATH
		if localization != null:
			title_label.text = localization.tr_key("interwin.level1.title", "Quest 1 Complete")
			body_label.text = localization.tr_key(
				"interwin.level1.body",
				"You have completed the first quest. The journey is still long!"
			)
			next_label.text = localization.tr_key("interwin.level1.next", "Quest 2: The Snowy Mountains")
		else:
			title_label.text = "Quest 1 Complete"
			body_label.text = "You have completed the first quest. The journey is still long!"
			next_label.text = "Quest 2: The Snowy Mountains"
	else:
		_next_scene_path = FINAL_LEVEL_PATH
		if localization != null:
			title_label.text = localization.tr_key("interwin.level2.title", "Quest 2 Complete")
			body_label.text = localization.tr_key(
				"interwin.level2.body",
				"The final quest awaits at the Castle Ruins, where the evil dragon resides."
			)
			next_label.text = localization.tr_key("interwin.level2.next", "Final Quest: Castle Ruins")
		else:
			title_label.text = "Quest 2 Complete"
			body_label.text = "The final quest awaits at the Castle Ruins, where the evil dragon resides."
			next_label.text = "Final Quest: Castle Ruins"

	if localization != null:
		start_button.text = localization.tr_key("interwin.start", "Start")
	else:
		start_button.text = "Start"

func _on_start_pressed() -> void:
	if _next_scene_path.is_empty():
		return
	get_tree().change_scene_to_file(_next_scene_path)
