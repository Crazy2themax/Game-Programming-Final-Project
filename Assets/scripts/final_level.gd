extends Node2D

const FALLING_ROCK_SCENE := preload("res://Assets/scenes/falling_rock_obstacle.tscn")
const FLOATING_TILE_SCENE := preload("res://Assets/scenes/floating_tile.tscn")

@export_range(1, 5, 1) var rocks_per_fire := 2
@export var top_spawn_y := -64.0
@export var left_spawn_x := 0.0
@export var dragon_exclusion_radius := 220.0
@export_range(4, 24, 1) var floating_tile_count := 10
@export var floating_start_x := 220.0
@export var floating_start_y := 470.0
@export var floating_first_tile_drop := 60.0
@export var floating_min_step_x := 170.0
@export var floating_max_step_x := 260.0
@export var floating_base_step_up := 32.0
@export var floating_first_gap_x := 250.0
@export var floating_first_step_up := 56.0
@export var floating_jitter_y := 28.0
@export var floating_min_y := 190.0
@export var floating_max_y := 500.0
@export var floating_dragon_clearance := 280.0
@export_range(0.0, 1.0, 0.01) var floating_helper_chance := 0.65
@export var floating_helper_jitter_y := 24.0
@export_range(0.0, 1.0, 0.01) var floating_quarter_main_chance := 0.2
@export_range(0.0, 1.0, 0.01) var floating_quarter_helper_chance := 0.65
@export var floating_min_gap_x := 95.0
@export var floating_min_gap_y := 18.0
@export var victory_scene_path := "res://Assets/scenes/VictoryMenu.tscn"
@export_range(0.0, 3.0, 0.05) var victory_delay := 0.6

var rng := RandomNumberGenerator.new()
var victory_triggered := false

@onready var dragon: Node2D = get_node_or_null("Dragon") as Node2D
@onready var rock_container: Node2D = get_node_or_null("RockContainer") as Node2D
@onready var floating_tile_container: Node2D = get_node_or_null("FloatingTileContainer") as Node2D

func _ready() -> void:
	$Player.gravity = 400.0
	rng.randomize()
	if rock_container == null:
		rock_container = self
	if floating_tile_container == null:
		floating_tile_container = self
	if dragon == null:
		dragon = get_tree().get_first_node_in_group("dragon_boss") as Node2D
	if dragon != null and dragon.has_signal("dragon_died"):
		var died_callable := Callable(self, "_on_dragon_died")
		if not dragon.is_connected("dragon_died", died_callable):
			dragon.connect("dragon_died", died_callable)
	_spawn_floating_tiles()
	if dragon == null or not dragon.has_signal("fireball_launched"):
		push_warning("Final level rock spawner could not find dragon fireball signal.")
		return

	var launch_callable := Callable(self, "_on_dragon_fireball_launched")
	if not dragon.is_connected("fireball_launched", launch_callable):
		dragon.connect("fireball_launched", launch_callable)

func _on_dragon_fireball_launched() -> void:
	for _i in range(rocks_per_fire):
		_spawn_falling_rock()

func _on_dragon_died() -> void:
	if victory_triggered:
		return
	victory_triggered = true
	if victory_scene_path.is_empty():
		push_warning("Victory scene path is empty; cannot switch scenes.")
		return
	if victory_delay > 0.0:
		await get_tree().create_timer(victory_delay).timeout
	get_tree().change_scene_to_file(victory_scene_path)

func _spawn_falling_rock() -> void:
	var dragon_x := 1400.0
	if dragon != null:
		dragon_x = dragon.global_position.x

	var max_spawn_x := maxf(left_spawn_x, dragon_x - dragon_exclusion_radius)
	var spawn_x := rng.randf_range(left_spawn_x, max_spawn_x)
	var rock := FALLING_ROCK_SCENE.instantiate() as Area2D
	if rock == null:
		return

	rock_container.add_child(rock)
	rock.global_position = Vector2(spawn_x, top_spawn_y)

func _spawn_floating_tiles() -> void:
	var dragon_x := 1400.0
	if dragon != null:
		dragon_x = dragon.global_position.x

	var max_spawn_x := maxf(floating_start_x + floating_min_step_x, dragon_x - floating_dragon_clearance)
	var current_x := floating_start_x
	var current_y := clampf(floating_start_y + floating_first_tile_drop, floating_min_y, floating_max_y)
	var placed_positions: Array[Vector2] = []
	var spawned_count := 0
	var main_step_count := maxi(4, int(ceil(float(floating_tile_count) * 0.6)))

	for _i in range(main_step_count):
		if spawned_count >= floating_tile_count or current_x > max_spawn_x:
			break

		if _spawn_floating_tile(Vector2(current_x, current_y), placed_positions, rng.randf() < floating_quarter_main_chance):
			spawned_count += 1

		var next_x := current_x + rng.randf_range(floating_min_step_x, floating_max_step_x)
		var next_y := current_y - floating_base_step_up + rng.randf_range(-floating_jitter_y, floating_jitter_y)
		if _i == 0:
			next_x = current_x + maxf(floating_first_gap_x, rng.randf_range(floating_min_step_x, floating_max_step_x))
			next_y = current_y - floating_first_step_up + rng.randf_range(-floating_jitter_y * 0.45, floating_jitter_y * 0.45)
		next_y = clampf(next_y, floating_min_y, floating_max_y)

		if _i > 0 and spawned_count < floating_tile_count and next_x <= max_spawn_x and rng.randf() < floating_helper_chance:
			var helper_x := lerpf(current_x, next_x, rng.randf_range(0.38, 0.74))
			var helper_y := lerpf(current_y, next_y, rng.randf_range(0.35, 0.72)) + rng.randf_range(-floating_helper_jitter_y, floating_helper_jitter_y)
			var helper_position := Vector2(
				clampf(helper_x, floating_start_x, max_spawn_x),
				clampf(helper_y, floating_min_y, floating_max_y)
			)
			if _spawn_floating_tile(helper_position, placed_positions, rng.randf() < floating_quarter_helper_chance):
				spawned_count += 1

		current_x = next_x
		current_y = next_y

func _spawn_floating_tile(position: Vector2, placed_positions: Array[Vector2], use_quarter_tile: bool) -> bool:
	if not _can_place_floating_tile(position, placed_positions):
		return false

	var tile := FLOATING_TILE_SCENE.instantiate() as StaticBody2D
	if tile == null:
		return false

	floating_tile_container.add_child(tile)
	tile.global_position = position
	if tile.has_method("configure"):
		tile.call("configure", use_quarter_tile)
	placed_positions.append(position)
	return true

func _can_place_floating_tile(position: Vector2, placed_positions: Array[Vector2]) -> bool:
	for existing in placed_positions:
		if absf(position.x - existing.x) < floating_min_gap_x and absf(position.y - existing.y) < floating_min_gap_y:
			return false
	return true
