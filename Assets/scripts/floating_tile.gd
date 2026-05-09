extends StaticBody2D

const FULL_TILE_TEXTURE := preload("res://Assets/final-level/SPECIAL/float-tile.png")
const QUARTER_TILE_TEXTURE := preload("res://Assets/final-level/SPECIAL/float-tile-quarter.png")

const FULL_TILE_SIZE := Vector2(110, 25)
const QUARTER_TILE_SIZE := Vector2(70, 25)

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("floating_tile")
	add_to_group("fireball_pass_through")
	configure(false)

func configure(use_quarter_tile: bool) -> void:
	if sprite == null or collision_shape == null:
		return

	var shape := collision_shape.shape as RectangleShape2D
	if shape == null:
		shape = RectangleShape2D.new()
		collision_shape.shape = shape

	if use_quarter_tile:
		sprite.texture = QUARTER_TILE_TEXTURE
		shape.size = QUARTER_TILE_SIZE
	else:
		sprite.texture = FULL_TILE_TEXTURE
		shape.size = FULL_TILE_SIZE

func hit_by_fireball() -> void:
	queue_free()
