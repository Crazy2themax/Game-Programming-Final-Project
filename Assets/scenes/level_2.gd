extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.gravity = 590.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameSession.go_to_fail_menu(get_tree(), "falling into the abyss")

func level_restart():
	pass


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://Assets/scenes/in-middle-level-win.tscn")
