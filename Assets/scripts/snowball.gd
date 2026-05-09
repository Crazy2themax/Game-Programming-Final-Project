extends Area2D

const SPEED := 250.0
var direction := Vector2.LEFT  # default throws left, adjust per reindeer facing

func _ready() -> void:
	body_entered.connect(_on_area_2d_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.apply_enemy_hit(1, "a snowball")
		queue_free()
	elif body is StaticBody2D:  # hits a wall or floor
		queue_free()
