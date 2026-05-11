extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.gravity = 590.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_key_for_next_level_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set("has_key", true)
		$KeyForNextLevel.hide()
		$KeyForNextLevel/CollisionShape2D.set_deferred("disabled", true)  # stops further triggers
		$KeyForNextLevel.queue_free()

func _on_door_to_next_level_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.get("has_key"):
		get_tree().change_scene_to_file("res://Assets/scenes/in-middle-level-win.tscn")

func _on_abyss_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameSession.go_to_fail_menu(get_tree(), "falling into the abyss")
 
