extends Control

func _localization() -> Node:
	return get_node_or_null("/root/Localization")

func _ready() -> void:
	var localization := _localization()
	if localization != null:
		localization.language_changed.connect(_on_language_changed)
	update_language()

func _exit_tree() -> void:
	var localization := _localization()
	if localization != null and localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.disconnect(_on_language_changed)

func update_language() -> void:
	var localization := _localization()
	if localization == null:
		$CenterContainer/VBoxContainer/TitleLabel.text = "Victory!"
		$CenterContainer/VBoxContainer/MessageLabel.text = "The Dragon Has Been Defeated. You saved the princess and brought peace back to the kingdom."
		$CenterContainer/VBoxContainer/ButtonsRow/ExitButton.text = "EXIT"
		return

	$CenterContainer/VBoxContainer/TitleLabel.text = localization.tr_key("victory.title", "Victory!")
	$CenterContainer/VBoxContainer/MessageLabel.text = localization.tr_key("victory.message", "The Dragon Has Been Defeated. You saved the princess and brought peace back to the kingdom.")
	$CenterContainer/VBoxContainer/ButtonsRow/ExitButton.text = localization.tr_key("victory.exit", "EXIT")

func _on_language_changed(_language_code: String) -> void:
	update_language()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
