extends Control


const SETTINGS_PATH := "user://settings.cfg"

@onready var click_player: AudioStreamPlayer2D = $"Options Panel/Sound Effect Slider/AudioStreamPlayer2D"


func _localization():
	return get_node_or_null("/root/Localization")


func _ready() -> void:
	var localization = _localization()
	if localization != null:
		localization.language_changed.connect(_on_language_changed)
	load_settings()
	update_language()


func _exit_tree() -> void:
	var localization = _localization()
	if localization != null and localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.disconnect(_on_language_changed)

func update_language():
	var localization = _localization()
	if localization == null:
		return

	$Panel/Label.text = localization.tr_key("menu.title", "IronVeil")
	$MenuContainer/Start_button.text = localization.tr_key("menu.start", "Start")
	$MenuContainer/Options_button.text = localization.tr_key("menu.options", "Options")
	$MenuContainer/Language_button.text = localization.get_language_button_text()
	$MenuContainer/Endgame_button.text = localization.tr_key("menu.quit", "End Game")

	$"Options Panel/Media Label".text = localization.tr_key("options.audio", "Audio")
	$"Options Panel/Master Label".text = localization.tr_key("options.master", "Master")
	$"Options Panel/Current Languages label".text = "%s: %s" % [
		localization.tr_key("options.current_language", "Current Language"),
		localization.get_current_language_name()
	]
	$"Options Panel/Music Label".text = localization.tr_key("options.music", "Music")
	$"Options Panel/Sound Effect Label".text = localization.tr_key("options.sfx", "Sound Effects")
	$"Options Panel/Fullscreen label".text = localization.tr_key("options.fullscreen", "Fullscreen")
	$"Options Panel/Save_button".text = localization.tr_key("options.save", "Save")

func save_settings():
	var config = ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("audio", "master", $"Options Panel/Master Sound Slider".value)
	config.set_value("audio", "music", $"Options Panel/Music Slider".value)
	config.set_value("audio", "sfx", $"Options Panel/Sound Effect Slider".value)
	config.set_value("display", "fullscreen", $"Options Panel/CheckBox".button_pressed)
	config.save(SETTINGS_PATH)

func load_settings():
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		$"Options Panel/Master Sound Slider".value = config.get_value("audio", "master", 1.0)
		$"Options Panel/Music Slider".value = config.get_value("audio", "music", 1.0)
		$"Options Panel/Sound Effect Slider".value = config.get_value("audio", "sfx", 1.0)
		$"Options Panel/CheckBox".button_pressed = config.get_value("display", "fullscreen", false)

	_apply_audio_settings()
	_apply_display_settings($"Options Panel/CheckBox".button_pressed)

func _on_language_changed(_language_code: String) -> void:
	update_language()


func _play_click() -> void:
	if is_instance_valid(click_player):
		click_player.play()


func _on_language_button_pressed() -> void:
	_play_click()
	var localization = _localization()
	if localization != null:
		localization.toggle_language()


func _on_english_button_pressed() -> void:
	_play_click()
	var localization = _localization()
	if localization != null:
		localization.set_language("en")

func _on_french_button_pressed() -> void:
	_play_click()
	var localization = _localization()
	if localization != null:
		localization.set_language("fr")

func _on_options_button_pressed() -> void:
	_play_click()
	$"Options Panel".visible = true
	$MenuContainer.visible = false

func _on_start_button_pressed() -> void:
	_play_click()
	get_tree().change_scene_to_file("res://Assets/scenes/Background.tscn")
	print("open new scene")

func _on_endgame_button_pressed() -> void:
	_play_click()
	get_tree().quit()

func _on_save_button_pressed() -> void:
	_play_click()
	save_settings()
	$"Options Panel".visible = false
	$MenuContainer.visible = true

func _on_master_sound_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(value)
	)

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("background"),
		linear_to_db(value)
	)

func _on_sound_effect_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Sound effect"),
		linear_to_db(value)
	)


func _apply_audio_settings() -> void:
	_on_master_sound_slider_value_changed($"Options Panel/Master Sound Slider".value)
	_on_music_slider_value_changed($"Options Panel/Music Slider".value)
	_on_sound_effect_slider_value_changed($"Options Panel/Sound Effect Slider".value)


func _on_check_box_toggled(toggled_on: bool) -> void:
	_apply_display_settings(toggled_on)


func _apply_display_settings(use_fullscreen: bool) -> void:
	if use_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
