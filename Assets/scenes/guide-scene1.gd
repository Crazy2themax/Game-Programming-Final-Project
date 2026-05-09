extends Control

const MENU_SCENE_PATH := "res://Assets/scenes/MainMenu.tscn"
const NEXT_SCENE_PATH := "res://Assets/scenes/guide-scene-2.tscn"

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
	prev_button.pressed.connect(_on_menu_pressed)
	next_button.pressed.connect(_on_next_pressed)

func _exit_tree() -> void:
	var localization := _localization()
	if localization != null and localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.disconnect(_on_language_changed)

func _on_language_changed(_language_code: String) -> void:
	_update_texts()

func _update_texts() -> void:
	var localization := _localization()
	if localization == null:
		title_label.text = "The Last Knight's Quest"
		subtitle_label.text = "The kingdom lies in shadow."
		body_label.text = "The western lands have burned under the wrath of an evil dragon. Villages have fallen, the kingdom has been broken, and the princess has been taken far away to the Castle of Ruins.\n\nOnly one knight remains brave enough to follow the dragon's path. His journey begins deep in the forest, where old camps, broken roads, and hidden dangers mark the first step of the quest.\n\nThe knight must move forward, survive every trial, and gather what he needs to reach the castle. Each path brings him closer to the dragon, the princess, and the final battle that will decide the fate of the kingdom."
		list_title.text = "The knight must:"
		list_item_1.text = "- Follow the forest path and reach the northern pass."
		list_item_2.text = "- Keep his blade ready against enemies and dangers."
		list_item_3.text = "- Collect keys to unlock the way forward."
		list_item_4.text = "- Gather hearts or life potions to restore his strength."
		list_item_5.text = "- Survive each quest to continue the journey."
		footer_label.text = "If the knight falls, he rises again from the quest he last reached."
		menu_button.text = "Menu"
		prev_button.text = "Previous"
		next_button.text = "Next"
		return

	title_label.text = localization.tr_key("guide1.title", "The Last Knight's Quest")
	subtitle_label.text = localization.tr_key("guide1.subtitle", "The kingdom lies in shadow.")
	body_label.text = localization.tr_key(
		"guide1.body",
		"The western lands have burned under the wrath of an evil dragon. Villages have fallen, the kingdom has been broken, and the princess has been taken far away to the Castle of Ruins.\n\nOnly one knight remains brave enough to follow the dragon's path. His journey begins deep in the forest, where old camps, broken roads, and hidden dangers mark the first step of the quest.\n\nThe knight must move forward, survive every trial, and gather what he needs to reach the castle. Each path brings him closer to the dragon, the princess, and the final battle that will decide the fate of the kingdom."
	)
	list_title.text = localization.tr_key("guide1.list_title", "The knight must:")
	list_item_1.text = localization.tr_key("guide1.list.item1", "- Follow the forest path and reach the northern pass.")
	list_item_2.text = localization.tr_key("guide1.list.item2", "- Keep his blade ready against enemies and dangers.")
	list_item_3.text = localization.tr_key("guide1.list.item3", "- Collect keys to unlock the way forward.")
	list_item_4.text = localization.tr_key("guide1.list.item4", "- Gather hearts or life potions to restore his strength.")
	list_item_5.text = localization.tr_key("guide1.list.item5", "- Survive each quest to continue the journey.")
	footer_label.text = localization.tr_key("guide1.footer", "If the knight falls, he rises again from the quest he last reached.")
	menu_button.text = localization.tr_key("guide.menu", "Menu")
	prev_button.text = localization.tr_key("guide.previous", "Previous")
	next_button.text = localization.tr_key("guide.next", "Next")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

func _on_next_pressed() -> void:
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)
