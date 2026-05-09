extends Area2D

@export var fall_speed := 320.0
@export var despawn_y := 760.0
@export var settled_lifetime := 3.0
@export var rock_textures: Array[Texture2D] = []

var rng := RandomNumberGenerator.new()
var is_settled := false
var settled_time := 0.0

@onready var rock_sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	rng.randomize()
	if rock_sprite != null and rock_textures.size() > 0:
		rock_sprite.texture = rock_textures[rng.randi_range(0, rock_textures.size() - 1)]

func _physics_process(delta: float) -> void:
	if is_settled:
		settled_time += delta
		if settled_time >= settled_lifetime:
			queue_free()
		return
	global_position.y += fall_speed * delta
	if global_position.y > despawn_y:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == null or is_settled:
		return
	if body.is_in_group("dragon_boss"):
		return
	if body.is_in_group("player"):
		if body.has_method("apply_enemy_hit"):
			body.apply_enemy_hit(1, "rocks from dragon rumbling")
		queue_free()
		return
	if body is StaticBody2D or body is TileMapLayer:
		_settle_on_ground()

func _settle_on_ground() -> void:
	is_settled = true
	settled_time = 0.0
	monitoring = false
