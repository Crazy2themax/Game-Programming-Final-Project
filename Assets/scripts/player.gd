extends CharacterBody2D

const SPEED = 150.0
const GRAVITY = 800.0
const JUMP_VELOCITY = -300.0

enum State { IDLE, RUN, ATTACK, JUMP }

var current_state: State = State.IDLE

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D  # changed

func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)
	$Camera2D.make_current()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	match current_state:
		State.IDLE:   handle_idle()
		State.RUN:    handle_run()
		State.ATTACK: handle_attack()
		State.JUMP:   handle_jump()
	move_and_slide()

func handle_idle() -> void:
	velocity.x = 0
	play_anim("idle")
	if Input.is_action_just_pressed("jump") and is_on_floor():
		change_state(State.JUMP)
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		change_state(State.RUN)
	elif Input.is_action_just_pressed("attack_1"):
		change_state(State.ATTACK)

func handle_run() -> void:
	play_anim("run")                          # was "walk" — new sprite uses "run"
	var dir = Input.get_axis("move_left", "move_right")
	velocity.x = dir * SPEED
	if dir != 0:
		anim.flip_h = dir < 0               # flip is on AnimatedSprite2D directly
	if Input.is_action_just_pressed("jump") and is_on_floor():
		change_state(State.JUMP)
	elif dir == 0:
		change_state(State.IDLE)
	elif Input.is_action_just_pressed("attack_1"):
		change_state(State.ATTACK)

func handle_jump() -> void:
	play_anim("jump")
	var dir = Input.get_axis("move_left", "move_right")
	velocity.x = dir * SPEED
	if dir != 0:
		anim.flip_h = dir < 0
	if is_on_floor():
		change_state(State.IDLE)

func handle_attack() -> void:
	velocity.x = 0
	play_anim("attack")                       # new sprite has one "attack", not attack_1/2

func _on_animation_finished() -> void:        # AnimatedSprite2D signal has no argument
	match anim.animation:
		"attack":
			change_state(State.IDLE)
		"hurt":
			change_state(State.IDLE)
		"death":
			pass                              # stay dead

func change_state(new_state: State) -> void:
	current_state = new_state
	if new_state == State.JUMP:
		velocity.y = JUMP_VELOCITY

func play_anim(anim_name: String) -> void:
	if anim.animation != anim_name:           # AnimatedSprite2D uses .animation not .current_animation
		anim.play(anim_name)
