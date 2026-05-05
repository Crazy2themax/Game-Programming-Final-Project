extends Node

signal language_changed(language_code: String)

const DEFAULT_LANGUAGE := "en"
const SETTINGS_PATH := "user://settings.cfg"
const TRANSLATION_CSV_PATH := "res://Localization/strings.csv"

var current_language := DEFAULT_LANGUAGE
var _translations: Dictionary = {}


func _ready() -> void:
	_load_translations()
	_load_settings()


func tr_key(key: String, fallback: String = "") -> String:
	var current_table: Dictionary = _translations.get(current_language, {})
	if current_table.has(key):
		return String(current_table[key])

	var default_table: Dictionary = _translations.get(DEFAULT_LANGUAGE, {})
	if default_table.has(key):
		return String(default_table[key])

	if not fallback.is_empty():
		return fallback

	return key


func set_language(language_code: String, should_save: bool = true) -> void:
	var normalized_code := language_code.to_lower()
	if not _translations.has(normalized_code):
		normalized_code = DEFAULT_LANGUAGE

	current_language = normalized_code
	TranslationServer.set_locale(current_language)

	if should_save:
		_save_settings()

	language_changed.emit(current_language)


func toggle_language() -> void:
	if current_language == "fr":
		set_language("en")
	else:
		set_language("fr")


func get_current_language_name() -> String:
	return tr_key("language.name.%s" % current_language, current_language.to_upper())


func get_language_button_text() -> String:
	return "%s: %s" % [tr_key("menu.language", "Language"), get_current_language_name()]


func get_action_display_name(action_name: String) -> String:
	for event in InputMap.action_get_events(action_name):
		var display_name := _event_to_text(event)
		if not display_name.is_empty():
			return display_name

	return action_name


func _load_translations() -> void:
	_translations.clear()

	var file := FileAccess.open(TRANSLATION_CSV_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open translation CSV at %s" % TRANSLATION_CSV_PATH)
		return

	if file.eof_reached():
		return

	var headers := file.get_csv_line()
	var language_columns: Array[String] = []
	for index in range(1, headers.size()):
		var language_code := String(headers[index]).strip_edges()
		language_columns.append(language_code)
		if not language_code.is_empty():
			_translations[language_code] = {}

	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.is_empty():
			continue

		var key := String(row[0]).strip_edges()
		if key.is_empty() or key.begins_with("#"):
			continue

		for index in range(1, min(row.size(), headers.size())):
			var language_code := language_columns[index - 1]
			if language_code.is_empty():
				continue
			_translations[language_code][key] = String(row[index])


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		set_language(String(config.get_value("language", "lang", DEFAULT_LANGUAGE)), false)
		return

	TranslationServer.set_locale(current_language)


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("language", "lang", current_language)
	config.save(SETTINGS_PATH)


func _event_to_text(event: InputEvent) -> String:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var keycode := key_event.physical_keycode if key_event.physical_keycode != 0 else key_event.keycode
		return _keycode_to_text(keycode)

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return _mouse_button_to_text(mouse_event.button_index)

	return ""


func _keycode_to_text(keycode: Key) -> String:
	match keycode:
		KEY_SPACE:
			return tr_key("input.space", "Space")
		KEY_LEFT:
			return tr_key("input.left_arrow", "Left Arrow")
		KEY_RIGHT:
			return tr_key("input.right_arrow", "Right Arrow")
		KEY_UP:
			return tr_key("input.up_arrow", "Up Arrow")
		_:
			return OS.get_keycode_string(keycode)


func _mouse_button_to_text(button_index: MouseButton) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT:
			return tr_key("input.left_mouse", "Left Mouse Button")
		_:
			return "Mouse %s" % button_index
