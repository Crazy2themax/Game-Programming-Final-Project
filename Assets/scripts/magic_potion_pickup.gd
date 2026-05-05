extends Area2D
class_name MagicPotionPickup

@export_range(8.0, 96.0, 0.5) var desired_pixel_height := 42.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_visual_scale()

func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("activate_dragon_slayer_potion"):
		return

	body.activate_dragon_slayer_potion()
	monitoring = false
	hide()
	queue_free()

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
		circle.radius = maxf(desired_pixel_height * 0.45, 8.0)