extends CharacterBody2D

const SNOWBALL = preload("res://Assets/scenes/snowball.tscn")

var player_in_range := false
var dead := false

@onready var throw_timer: Timer = $ThrowTimer
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection: Area2D = $AreaOfAttack

func _ready() -> void:
	detection.body_entered.connect(_on_area_of_attack_body_entered)
	detection.body_exited.connect(_on_area_of_attack_body_exited)
	anim.animation_finished.connect(_on_animation_finished)
	anim.play("idle")


func _on_animation_finished() -> void:
	if dead:
		queue_free()  # removes reindeer after death animation
	elif anim.animation == "attack" and player_in_range:
		_throw_snowball()
		print("throw snoball")
		anim.play("attack")  # keeps looping attack while player is close
		

func apply_enemy_hit(amount: int = 1, cause: String = "") -> void:
	if dead:
		return
	dead = true
	player_in_range = false
	detection.monitoring = false  # stops detecting while dying
	anim.play("death")

func _throw_snowball() -> void:
	var ball = SNOWBALL.instantiate()
	get_parent().add_child(ball)
	ball.global_position = global_position
	ball.direction = Vector2.LEFT
	print("throw snoball")

func _on_area_of_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not dead:
		player_in_range = true
		anim.play("attack")
		throw_timer.start(1.5)

func _on_area_of_attack_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not dead:
		player_in_range = false
		anim.play("idle")
		throw_timer.stop()
