extends Node

const FAIL_MENU_PATH := "res://Assets/scenes/FailMenu.tscn"
const FIRST_LEVEL_PATH := "res://Assets/scenes/Background.tscn"

var highest_level_reached := 1
var current_level := 1
var restart_scene_path := FIRST_LEVEL_PATH
var last_death_cause := ""

func start_new_run() -> void:
	highest_level_reached = 1
	current_level = 1
	restart_scene_path = FIRST_LEVEL_PATH
	last_death_cause = ""

func register_level(level_number: int, scene_path: String) -> void:
	current_level = maxi(level_number, 1)
	highest_level_reached = maxi(highest_level_reached, current_level)
	if not scene_path.is_empty():
		restart_scene_path = scene_path
	last_death_cause = ""

func get_highest_level_reached() -> int:
	return highest_level_reached

func get_restart_scene_path() -> String:
	return restart_scene_path if not restart_scene_path.is_empty() else FIRST_LEVEL_PATH

func set_death_cause(cause: String) -> void:
	last_death_cause = cause.strip_edges()

func get_death_cause() -> String:
	return last_death_cause

func go_to_fail_menu(tree: SceneTree, death_cause: String = "") -> void:
	if tree == null:
		return
	if not death_cause.strip_edges().is_empty():
		set_death_cause(death_cause)
	tree.change_scene_to_file(FAIL_MENU_PATH)
