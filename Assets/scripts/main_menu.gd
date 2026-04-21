extends Control

var flags = {
	"en": preload("res://assets/images/en.webp"),
	"fr": preload("res://assets/images/fr.jpg"),
	"es": preload("res://assets/images/es.webp")
}
var current_lang = "en"
var translations = {
	"en": {
		"title": "Ironveil",
		"play": "Start",
		"options": "Options",
		"exit": "End Game",
		"current_lang": "Current Language",
		"language": "Languages",
		"audio": "Media",
		"master": "Master",
		"music": "Music",
		"sfx": "Sound Effects",
		"fullscreen": "Fullscreen",
		"save": "Save"
	},
	"fr": {
		"title": "Le Voile de Fer",
		"play": "Commencer",
		"options": "Options",
		"exit": "Quitter le Jeu",
		"current_lang": "Langue Actuelle",
		"language": "Langues",
		"audio": "Média",
		"master": "Principal",
		"music": "Musique",
		"sfx": "Effets Sonores",
		"fullscreen": "Plein Écran",
		"save": "Sauvegarder"
	},
	"es": {
		"title": "El Velo de Hierro",
		"play": "Comenzar",
		"options": "Opciones",
		"exit": "Salir del Juego",
		"current_lang": "Idioma Actual",
		"language": "Idiomas",
		"audio": "Medios",
		"master": "Principal",
		"music": "Música",
		"sfx": "Efectos de Sonido",
		"fullscreen": "Pantalla Completa",
		"save": "Guardar"
	},
}

func _ready() -> void:
	load_settings()
	update_language()
	$"Options Panel/FlagImage".texture = flags[current_lang]
func update_flag():
	$"Options Panel/FlagImage".texture = flags[current_lang]
	
	
func update_language():
	var t = translations[current_lang]
	
	# Main menu
	$Panel/Label.text = t["title"]
	$MenuContainer/Start_button.text = t["play"]
	$MenuContainer/Options_button.text = t["options"]
	$MenuContainer/Endgame_button.text = t["exit"]
	
	# Options menu
	$"Options Panel/Languages_label".text = t["language"]
	$"Options Panel/Media Label".text = t["audio"]
	$"Options Panel/Master Label".text = t["master"]
	$"Options Panel/Current Languages label".text = t["current_lang"]
	$"Options Panel/Music Label".text = t["music"]
	$"Options Panel/Sound Effect Label".text = t["sfx"]
	$"Options Panel/Fullscreen label".text = t["fullscreen"]
	$"Options Panel/Save_button".text = t["save"]

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "Master", $"Options Panel/Master Sound Slider".value)
	config.set_value("audio", "background", $"Options Panel/Music Slider".value)
	config.set_value("audio", "Sound effect", $"Options Panel/Sound Effect Slider".value)
	config.set_value("display", "fullscreen", $"Options Panel/CheckBox".button_pressed)
	config.set_value("language", "lang", current_lang)
	config.save("user://settings.cfg")

func load_settings():
	
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		$"Options Panel/Master Sound Slider".value = config.get_value("audio", "master", 1.0)
		$"Options Panel/Music Slider".value = config.get_value("audio", "music", 1.0)
		$"Options Panel/Sound Effect Slider".value = config.get_value("audio", "sfx", 1.0)
		$"Options Panel/CheckBox".button_pressed = config.get_value("display", "fullscreen", false)
		current_lang = config.get_value("language", "lang", "en")

# Language buttons
func _on_english_button_pressed() -> void:
	$"Options Panel/Sound Effect Slider/AudioStreamPlayer2D".play()
	current_lang = "en"
	update_flag() 
	update_language()
	

func _on_french_button_pressed() -> void:
	$"Options Panel/Sound Effect Slider/AudioStreamPlayer2D".play()
	current_lang = "fr"
	update_flag() 
	update_language()

func _on_spanish_button_pressed() -> void:
	$"Options Panel/Sound Effect Slider/AudioStreamPlayer2D".play()
	current_lang = "es"
	update_flag() 
	update_language()

# Main Menu navigation
func _on_options_button_pressed() -> void:
	$"Options Panel/Sound Effect Slider/AudioStreamPlayer2D".play()
	$"Options Panel".visible = true
	$MenuContainer.visible = false

func _on_start_button_pressed() -> void:
	$"Options Panel/Sound Effect Slider/AudioStreamPlayer2D".play()
	get_tree().change_scene_to_file("res://scenes/gameplay.tscn")
	print("open new scene")

func _on_endgame_button_pressed() -> void:
	$"Options Panel/Sound Effect Slider/AudioStreamPlayer2D".play()
	get_tree().quit()

func _on_save_button_pressed() -> void:
	
	$"Options Panel/Sound Effect Slider/AudioStreamPlayer2D".play()
	save_settings()
	$"Options Panel".visible = false
	$MenuContainer.visible = true

# Audio sliders
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


func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
