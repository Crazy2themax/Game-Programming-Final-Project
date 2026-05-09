extends Area2D

# Change this to your next level's path
@export var next_level: String = "res://Scenes/level_2.tscn"

func _ready():
	$AnimatedSprite2D.play("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.is_dead = true  # freeze player input
		$AnimatedSprite2D.play("enter")
		await get_tree().create_timer(1.0).timeout
		SceneManager.change_scene(next_level, {
			"pattern": "res://addons/scene_manager/shader_patterns/vertical.png",
			"speed": 6,
			"color": Color.BLACK
		})
