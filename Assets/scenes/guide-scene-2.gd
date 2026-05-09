extends Control

const MENU_SCENE_PATH := "res://Assets/scenes/MainMenu.tscn"
const PREV_SCENE_PATH := "res://Assets/scenes/guide-scene1.tscn"
const START_LEVEL_PATH := "res://Assets/scenes/Background.tscn"

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $MarginContainer/VBoxContainer/SubtitleLabel
@onready var body_label: Label = $MarginContainer/VBoxContainer/BodyLabel
@onready var list_title: Label = $MarginContainer/VBoxContainer/ListTitle
@onready var list_item_1: Label = $MarginContainer/VBoxContainer/ListContainer/ListItem1
@onready var list_item_2: Label = $MarginContainer/VBoxContainer/ListContainer/ListItem2
@onready var list_item_3: Label = $MarginContainer/VBoxContainer/ListContainer/ListItem3
@onready var list_item_4: Label = $MarginContainer/VBoxContainer/ListContainer/ListItem4
@onready var list_item_5: Label = $MarginContainer/VBoxContainer/ListContainer/ListItem5
@onready var footer_label: Label = $MarginContainer/VBoxContainer/FooterLabel
@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButtonContainer/StartGameButton
@onready var menu_button: Button = $MarginContainer/VBoxContainer/ButtonRow/MenuButton
@onready var prev_button: Button = $MarginContainer/VBoxContainer/ButtonRow/PrevButton
@onready var next_button: Button = $MarginContainer/VBoxContainer/ButtonRow/NextButton

func _localization() -> Node:
	return get_node_or_null("/root/Localization")

func _ready() -> void:
	var localization := _localization()
	if localization != null:
		localization.language_changed.connect(_on_language_changed)
	_update_texts()
	menu_button.pressed.connect(_on_menu_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_start_pressed)
	start_button.pressed.connect(_on_start_pressed)

func _exit_tree() -> void:
	var localization := _localization()
	if localization != null and localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.disconnect(_on_language_changed)

func _on_language_changed(_language_code: String) -> void:
	_update_texts()

func _update_texts() -> void:
	var localization := _localization()
	if localization == null:
		title_label.text = "The Path Ahead"
		subtitle_label.text = "The final battle waits beyond the mountains."
		body_label.text = "The quest is divided into three dangerous paths. First, the knight must survive the dark Forest. Then, he must cross the frozen Snowy Mountains, where the cold and danger grow stronger.\n\nAt the end of the journey stands the Castle of Ruins, the dragon's lair. The castle is breaking apart from the dragon's power. Stones and bricks fall from above, fireballs tear through the halls, and every mistake can bring the knight closer to defeat.\n\nThe knight's life can survive 4 hits. If his life reaches 0, the quest fails, but he can restart from the level he reached."
		list_title.text = "Remember:"
		list_item_1.text = "- Avoid enemies, traps, fireballs, falling rocks, and falling bricks."
		list_item_2.text = "- Collect hearts or life potions to restore your life."
		list_item_3.text = "- Find the keys needed to continue through the quest."
		list_item_4.text = "- In the final level, collect the magic potion before facing the dragon."
		list_item_5.text = "- The potion gives the knight the power to defeat the dragon in one final strike."
		footer_label.text = "The princess waits. The kingdom hopes. The last knight must not fail."
		menu_button.text = "Menu"
		prev_button.text = "Previous"
		next_button.text = "Next"
		start_button.text = "Start Game"
		return

	title_label.text = localization.tr_key("guide2.title", "The Path Ahead")
	subtitle_label.text = localization.tr_key("guide2.subtitle", "The final battle waits beyond the mountains.")
	body_label.text = localization.tr_key(
		"guide2.body",
		"The quest is divided into three dangerous paths. First, the knight must survive the dark Forest. Then, he must cross the frozen Snowy Mountains, where the cold and danger grow stronger.\n\nAt the end of the journey stands the Castle of Ruins, the dragon's lair. The castle is breaking apart from the dragon's power. Stones and bricks fall from above, fireballs tear through the halls, and every mistake can bring the knight closer to defeat.\n\nThe knight's life can survive 4 hits. If his life reaches 0, the quest fails, but he can restart from the level he reached."
	)
	list_title.text = localization.tr_key("guide2.list_title", "Remember:")
	list_item_1.text = localization.tr_key("guide2.list.item1", "- Avoid enemies, traps, fireballs, falling rocks, and falling bricks.")
	list_item_2.text = localization.tr_key("guide2.list.item2", "- Collect hearts or life potions to restore your life.")
	list_item_3.text = localization.tr_key("guide2.list.item3", "- Find the keys needed to continue through the quest.")
	list_item_4.text = localization.tr_key("guide2.list.item4", "- In the final level, collect the magic potion before facing the dragon.")
	list_item_5.text = localization.tr_key("guide2.list.item5", "- The potion gives the knight the power to defeat the dragon in one final strike.")
	footer_label.text = localization.tr_key("guide2.footer", "The princess waits. The kingdom hopes. The last knight must not fail.")
	menu_button.text = localization.tr_key("guide.menu", "Menu")
	prev_button.text = localization.tr_key("guide.previous", "Previous")
	next_button.text = localization.tr_key("guide.next", "Next")
	start_button.text = localization.tr_key("guide.start_game", "Start Game")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

func _on_prev_pressed() -> void:
	get_tree().change_scene_to_file(PREV_SCENE_PATH)

func _on_start_pressed() -> void:
	GameSession.start_new_run()
	get_tree().change_scene_to_file(START_LEVEL_PATH)
