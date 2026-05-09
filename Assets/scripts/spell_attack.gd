extends Area2D

var direction = Vector2.RIGHT
const SPEED = 250.0

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(6.0).timeout
	if is_inside_tree():
		queue_free()

func _process(delta):
	# Move in the full 2D direction including vertical and diagonal
	position += direction * SPEED * delta

func set_direction(dir: Vector2):
	direction = dir.normalized()
	# Flip sprite horizontally based on x direction
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.flip_h = direction.x < 0
	# Rotate the spell sprite to face the direction it travels
	rotation = direction.angle()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.apply_enemy_hit(1, "a necromancer spell")
		# Disable collision immediately so no second hit registers
		# before the node is fully removed next frame
		$CollisionShape2D.set_deferred("disabled", true)
		# Hide it instantly so it visually vanishes right away
		visible = false
		queue_free()
