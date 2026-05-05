extends Area2D

@export var speed := 500.0
@export var max_travel_time := 3.0

var direction := Vector2.LEFT
var travel_time := 0.0
var active := false
var spawn_point: Marker2D
var dragon_owner: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	hide()
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if not active:
		return

	global_position += direction * speed * delta
	travel_time += delta
	if travel_time >= max_travel_time:
		reset_to_spawn()

func configure(new_spawn_point: Marker2D, new_owner: Node2D, launch_direction: Vector2 = Vector2.LEFT) -> void:
	spawn_point = new_spawn_point
	dragon_owner = new_owner
	direction = launch_direction.normalized()
	reset_to_spawn()

func is_ready_to_launch() -> bool:
	return not active

func launch() -> void:
	if spawn_point == null:
		push_warning("Fireball spawn point is missing.")
		return

	travel_time = 0.0
	active = true
	top_level = true
	global_position = spawn_point.global_position
	show()
	monitoring = true
	set_physics_process(true)

func reset_to_spawn() -> void:
	active = false
	travel_time = 0.0
	monitoring = false
	set_physics_process(false)
	hide()
	top_level = false
	position = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	if body == dragon_owner:
		return
	reset_to_spawn()

func _on_area_entered(area: Area2D) -> void:
	if area == self:
		return
	if dragon_owner != null and dragon_owner.is_ancestor_of(area):
		return
	reset_to_spawn()