extends CharacterBody2D
const SPEED = 150.0
const GRAVITY = 800.0
const JUMP_VELOCITY = -300.0
enum State { IDLE, RUN, ATTACK1, ATTACK2, JUMP }
var current_state: State = State.IDLE

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)
	$Camera2D.make_current()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	match current_state:
		State.IDLE:    handle_idle()
		State.RUN:     handle_run()
		State.ATTACK1: handle_attack1()
		State.ATTACK2: handle_attack2()
		State.JUMP:    handle_jump()
	move_and_slide()

func handle_idle() -> void:
	velocity.x = 0
	play_anim("idle")
	if Input.is_action_just_pressed("jump") and is_on_floor():
		change_state(State.JUMP)
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		change_state(State.RUN)
	elif Input.is_action_just_pressed("attack_1"):
		change_state(State.ATTACK1)
	elif Input.is_action_just_pressed("attack_2"):
		change_state(State.ATTACK2)

func handle_run() -> void:
	play_anim("walk")
	var dir = Input.get_axis("move_left", "move_right")
	velocity.x = dir * SPEED
	if dir != 0:
		sprite.flip_h = dir < 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		change_state(State.JUMP)
	elif dir == 0:
		change_state(State.IDLE)
	elif Input.is_action_just_pressed("attack_1"):
		change_state(State.ATTACK1)
	elif Input.is_action_just_pressed("attack_2"):
		change_state(State.ATTACK2)

func handle_jump() -> void:
	play_anim("jump")
	var dir = Input.get_axis("move_left", "move_right")
	velocity.x = dir * SPEED
	if dir != 0:
		sprite.flip_h = dir < 0
	if is_on_floor():
		change_state(State.IDLE)

func handle_attack1() -> void:
	velocity.x = 0
	play_anim("attack_1")

func handle_attack2() -> void:
	velocity.x = 0
	play_anim("attack_2")

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"attack_1":
			change_state(State.IDLE)
		"attack_2":
			change_state(State.IDLE)

func change_state(new_state: State) -> void:
	current_state = new_state
	if new_state == State.JUMP:
		velocity.y = JUMP_VELOCITY

func play_anim(name: String) -> void:
	if anim.current_animation != name:
		anim.play(name)
