extends Area2D

@export var next_level: String = "res://Scenes/level_2.tscn"

func _ready():
	$AnimatedSprite2D.play("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://Assets/scenes/in-middle-level-win.tscn")
