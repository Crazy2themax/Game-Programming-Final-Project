extends CanvasLayer
class_name UIInterface

@export_range(1, 99, 1) var level_number := 1
@export_range(1, 3600, 1) var countdown_seconds := 180
@export var restart_on_timeout := false

var remaining_seconds := 0
var bound_health: PlayerHealth
var bound_boss_health: PlayerHealth
var heart_pickup: HeartPickup

@onready var life_label: Label = $MarginContainer/PanelContainer/VBoxContainer/LifeContainer/LifeLabel
@onready var life_bar: ProgressBar = $MarginContainer/PanelContainer/VBoxContainer/LifeContainer/LifeBar
@onready var level_label: Label = $MarginContainer/PanelContainer/VBoxContainer/LevelLabel
@onready var countdown_label: Label = $MarginContainer/PanelContainer/VBoxContainer/CountdownLabel
@onready var life_potion_label: Label = $MarginContainer/PanelContainer/VBoxContainer/LifePotionLabel
@onready var boss_container: MarginContainer = $BossMarginContainer
@onready var boss_label: Label = $BossMarginContainer/PanelContainer/VBoxContainer/BossLabel
@onready var boss_bar: ProgressBar = $BossMarginContainer/PanelContainer/VBoxContainer/BossBar
@onready var countdown_timer: Timer = $CountdownTimer

func _localization() -> Node:
	return get_node_or_null("/root/Localization")

func _ready() -> void:
	remaining_seconds = countdown_seconds
	var localization := _localization()
	if localization != null:
		localization.language_changed.connect(_on_language_changed)
	var current_scene := get_tree().current_scene
	if current_scene != null:
		GameSession.register_level(level_number, current_scene.scene_file_path)
	countdown_timer.timeout.connect(_on_countdown_timer_timeout)
	boss_container.visible = false
	_update_static_labels()
	_update_level_label()
	_update_countdown_label()
	_update_life_potion_label()
	countdown_timer.start()
	call_deferred("_bind_scene_nodes")

func _exit_tree() -> void:
	var localization := _localization()
	if localization != null and localization.language_changed.is_connected(_on_language_changed):
		localization.language_changed.disconnect(_on_language_changed)

func bind_to_player(target: Node) -> void:
	var next_health: PlayerHealth = null
	if target != null and target.has_method("get_health_component"):
		next_health = target.get_health_component()

	if bound_health == next_health:
		return

	if bound_health != null and bound_health.health_changed.is_connected(_on_health_changed):
		bound_health.health_changed.disconnect(_on_health_changed)
	if bound_boss_health != null and bound_boss_health.health_changed.is_connected(_on_boss_health_changed):
		bound_boss_health.health_changed.disconnect(_on_boss_health_changed)

	bound_health = next_health
	if bound_health != null:
		bound_health.health_changed.connect(_on_health_changed)
		_on_health_changed(bound_health.current_health, bound_health.max_health)

func bind_to_dragon(target: Node) -> void:
	var next_health: PlayerHealth = null
	if target != null and target.has_method("get_health_component"):
		next_health = target.get_health_component()

	if bound_boss_health == next_health:
		return

	if bound_boss_health != null and bound_boss_health.health_changed.is_connected(_on_boss_health_changed):
		bound_boss_health.health_changed.disconnect(_on_boss_health_changed)

	bound_boss_health = next_health
	boss_container.visible = bound_boss_health != null
	if bound_boss_health != null:
		bound_boss_health.health_changed.connect(_on_boss_health_changed)
		_on_boss_health_changed(bound_boss_health.current_health, bound_boss_health.max_health)

func set_level(level_value: int) -> void:
	level_number = maxi(level_value, 1)
	if is_inside_tree():
		_update_level_label()

func set_countdown(seconds: int) -> void:
	countdown_seconds = maxi(seconds, 1)
	remaining_seconds = countdown_seconds
	if is_inside_tree():
		_update_countdown_label()

func _bind_scene_nodes() -> void:
	bind_to_player(get_tree().get_first_node_in_group("player"))
	bind_to_dragon(get_tree().get_first_node_in_group("dragon_boss"))
	heart_pickup = get_tree().get_first_node_in_group("heart_pickup") as HeartPickup
	_update_life_potion_label()

func _on_health_changed(current_health: int, max_health: int) -> void:
	life_bar.max_value = max_health
	life_bar.value = current_health

func _on_boss_health_changed(current_health: int, max_health: int) -> void:
	boss_bar.max_value = max_health
	boss_bar.value = current_health

func _on_countdown_timer_timeout() -> void:
	if remaining_seconds > 0:
		remaining_seconds -= 1
		_update_countdown_label()
	_update_life_potion_label()

	if remaining_seconds == 0:
		countdown_timer.stop()
		if restart_on_timeout:
			get_tree().reload_current_scene()

func _on_language_changed(_language_code: String) -> void:
	_update_static_labels()
	_update_level_label()
	_update_countdown_label()
	_update_life_potion_label()

func _update_static_labels() -> void:
	var localization := _localization()
	if localization == null:
		life_label.text = "Knight's Life"
		life_potion_label.text = "Life Potion: 00:00"
		boss_label.text = "Evil Dragon"
		return

	life_label.text = localization.tr_key("hud.knights_life", "Knight's Life")
	boss_label.text = "Evil Dragon"

func _update_life_potion_label() -> void:
	var localization := _localization()
	var prefix := "Life Potion"
	var ready_text := "Ready"
	if localization != null:
		prefix = localization.tr_key("hud.life_potion", "Life Potion")
		ready_text = localization.tr_key("hud.ready", "Ready")

	if heart_pickup == null:
		life_potion_label.text = "%s: --:--" % prefix
		return

	if heart_pickup.is_available():
		life_potion_label.text = "%s: %s" % [prefix, ready_text]
		return

	var seconds_left := heart_pickup.get_seconds_until_next_spawn()
	var minutes := seconds_left / 60
	var seconds := seconds_left % 60
	life_potion_label.text = "%s: %02d:%02d" % [prefix, minutes, seconds]

func _update_level_label() -> void:
	var localization := _localization()
	var prefix := "Quest"
	if localization != null:
		prefix = localization.tr_key("hud.quest", "Quest")
	level_label.text = "%s: %d" % [prefix, level_number]

func _update_countdown_label() -> void:
	var localization := _localization()
	var prefix := "Countdown"
	if localization != null:
		prefix = localization.tr_key("hud.countdown", "Countdown")
	var minutes := remaining_seconds / 60
	var seconds := remaining_seconds % 60
	countdown_label.text = "%s: %02d:%02d" % [prefix, minutes, seconds]
