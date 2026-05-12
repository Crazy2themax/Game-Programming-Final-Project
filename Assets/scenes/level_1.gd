extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.SPEED = 250.0  
		player.gravity = 500.0


func _on_abyss_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameSession.go_to_fail_menu(get_tree(), "falling into the abyss")
