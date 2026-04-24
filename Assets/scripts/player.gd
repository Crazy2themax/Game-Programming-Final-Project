extends CharacterBody2D

enum PlayerState { IDLE, RUN, JUMP, ATTACK, HURT, DEATH }

@export var move_speed := 220.0
@export var jump_velocity := -420.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

var state := PlayerState.IDLE


func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	camera.enabled = true
	_update_animation()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if state == PlayerState.DEATH:
		velocity.x = 0.0
		move_and_slide()
		_update_animation()
		return

	if state == PlayerState.ATTACK or state == PlayerState.HURT:
		velocity.x = 0.0
		move_and_slide()
		_update_animation()
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_just_pressed("attack_1") or Input.is_action_just_pressed("attack_2"):
		_start_attack()
	else:
		var direction := Input.get_axis("move_left", "move_right")
		if direction != 0.0:
			velocity.x = direction * move_speed
			animated_sprite.flip_h = direction < 0.0
		else:
			velocity.x = 0.0

	move_and_slide()

	if state != PlayerState.ATTACK and state != PlayerState.HURT and state != PlayerState.DEATH:
		state = _get_movement_state()

	_update_animation()


func play_hurt() -> void:
	if state == PlayerState.DEATH:
		return

	state = PlayerState.HURT
	velocity.x = 0.0
	_update_animation()


func play_death() -> void:
	state = PlayerState.DEATH
	velocity = Vector2.ZERO
	_update_animation()


func _start_attack() -> void:
	if state == PlayerState.DEATH:
		return

	state = PlayerState.ATTACK
	velocity.x = 0.0
	_update_animation()


func _get_movement_state() -> PlayerState:
	if not is_on_floor():
		return PlayerState.JUMP

	if abs(velocity.x) > 0.1:
		return PlayerState.RUN

	return PlayerState.IDLE


func _update_animation() -> void:
	var animation_name := &"idle"

	match state:
		PlayerState.RUN:
			animation_name = &"run"
		PlayerState.JUMP:
			animation_name = &"jump"
		PlayerState.ATTACK:
			animation_name = &"attack"
		PlayerState.HURT:
			animation_name = &"hurt"
		PlayerState.DEATH:
			animation_name = &"death"

	_play_animation(animation_name)


func _play_animation(animation_name: StringName) -> void:
	if animated_sprite.animation == animation_name:
		return

	animated_sprite.play(animation_name)


func _on_animation_finished() -> void:
	if state == PlayerState.ATTACK or state == PlayerState.HURT:
		state = _get_movement_state()
		_update_animation()
