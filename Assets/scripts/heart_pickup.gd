extends Area2D
class_name HeartPickup

@export_range(1.0, 64.0, 0.5) var desired_pixel_height := 35.0
@export_range(1.0, 120.0, 0.5) var initial_delay := 35.0
@export_range(0.5, 10.0, 0.5) var visible_duration := 3.0
@export_range(1.0, 60.0, 0.5) var hidden_duration := 20.0
@export var spawn_margin := Vector2(24.0, 24.0)
@export_range(0.0, 200.0, 1.0) var floor_clearance := 56.0
@export_range(4, 64, 1) var max_spawn_attempts := 18

var rng := RandomNumberGenerator.new()

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visible_timer: Timer = $VisibleTimer
@onready var hidden_timer: Timer = $HiddenTimer

func _ready() -> void:
	rng.randomize()
	add_to_group("heart_pickup")
	body_entered.connect(_on_body_entered)
	visible_timer.timeout.connect(_on_visible_timer_timeout)
	hidden_timer.timeout.connect(_on_hidden_timer_timeout)
	_apply_visual_scale()
	hide()
	monitoring = false
	hidden_timer.start(initial_delay)

func _on_body_entered(body: Node2D) -> void:
	if not visible:
		return
	if not body.has_method("restore_full_health"):
		return

	body.restore_full_health()
	_start_hidden_cycle()

func _on_visible_timer_timeout() -> void:
	_start_hidden_cycle()

func _on_hidden_timer_timeout() -> void:
	_show_at_random_position()

func _show_at_random_position() -> void:
	_relocate_randomly()
	show()
	monitoring = true
	visible_timer.start(visible_duration)

func _start_hidden_cycle() -> void:
	hide()
	monitoring = false
	visible_timer.stop()
	hidden_timer.start(hidden_duration)

func _apply_visual_scale() -> void:
	if sprite.texture == null:
		return

	var texture_height := float(sprite.texture.get_height())
	if texture_height <= 0.0:
		return

	var scale_factor := desired_pixel_height / texture_height
	sprite.scale = Vector2.ONE * scale_factor

	var circle := collision_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = maxf(desired_pixel_height * 0.75, 5.0)

func _relocate_randomly() -> void:
	var spawn_rect := _get_spawn_rect()
	if spawn_rect.size.x <= 0.0 or spawn_rect.size.y <= 0.0:
		return

	var world := get_world_2d()
	if world == null:
		return

	var space_state := world.direct_space_state
	for _attempt in range(max_spawn_attempts):
		var spawn_x := rng.randf_range(spawn_rect.position.x, spawn_rect.end.x)
		var ray_from := Vector2(spawn_x, spawn_rect.position.y)
		var ray_to := Vector2(spawn_x, spawn_rect.end.y + floor_clearance)
		var query := PhysicsRayQueryParameters2D.create(ray_from, ray_to)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		query.exclude = [self]
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			continue
		var normal: Vector2 = result["normal"]
		if normal.dot(Vector2.UP) < 0.75:
			continue
		var collision_point: Vector2 = result["position"]
		global_position = collision_point + Vector2.UP * (desired_pixel_height * 0.65)
		return

	global_position = Vector2(
		rng.randf_range(spawn_rect.position.x, spawn_rect.end.x),
		rng.randf_range(spawn_rect.position.y, spawn_rect.end.y)
	)

func _get_spawn_rect() -> Rect2:
	var scene := get_tree().current_scene
	if scene == null:
		return Rect2(Vector2.ZERO, get_viewport_rect().size)

	var tile_map := scene.get_node_or_null("TileMap")
	if tile_map == null:
		tile_map = scene.get_node_or_null("TileMapLayer")
	if tile_map != null and tile_map.has_method("get_used_rect") and tile_map.get("tile_set") != null:
		var used_rect: Rect2i = tile_map.get_used_rect()
		var tile_size: Vector2 = Vector2(tile_map.tile_set.tile_size)
		var tile_origin: Vector2 = tile_map.global_position + Vector2(used_rect.position) * tile_size
		var tile_extent: Vector2 = Vector2(used_rect.size) * tile_size
		return _shrink_spawn_rect(Rect2(tile_origin, tile_extent))

	var camera := get_viewport().get_camera_2d()
	if camera != null:
		var viewport_size := get_viewport_rect().size * camera.zoom
		var top_left := camera.get_screen_center_position() - viewport_size * 0.5
		return _shrink_spawn_rect(Rect2(top_left, viewport_size))

	return _shrink_spawn_rect(Rect2(Vector2.ZERO, get_viewport_rect().size))

func _shrink_spawn_rect(spawn_rect: Rect2) -> Rect2:
	var x_padding := maxf(spawn_margin.x, desired_pixel_height)
	var y_padding := maxf(spawn_margin.y, desired_pixel_height)
	spawn_rect.position.x += x_padding
	spawn_rect.position.y += y_padding
	spawn_rect.size.x = maxf(spawn_rect.size.x - x_padding * 2.0, 1.0)
	spawn_rect.size.y = maxf(spawn_rect.size.y - y_padding * 2.0 - floor_clearance, 1.0)
	return spawn_rect

func get_seconds_until_next_spawn() -> int:
	if visible:
		return 0
	return int(ceil(hidden_timer.time_left))

func is_available() -> bool:
	return visible
