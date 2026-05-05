extends CharacterBody2D

const SPEED = 150.0
const GRAVITY = 500.0
const JUMP_VELOCITY = -250.0

enum State { IDLE, RUN, ATTACK, JUMP, HURT, DEAD }

var current_state: State = State.IDLE

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_sfx: AudioStreamPlayer2D = $AttackSfx
@onready var health: PlayerHealth = $PlayerHealth

func _ready() -> void:
	add_to_group("player")
	anim.animation_finished.connect(_on_animation_finished)
	health.died.connect(_on_died)
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	match current_state:
		State.IDLE:   handle_idle()
		State.RUN:    handle_run()
		State.ATTACK: handle_attack()
		State.JUMP:   handle_jump()
		State.HURT:   handle_hurt()
		State.DEAD:   handle_dead()
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
	play_anim("run")
	var dir = Input.get_axis("move_left", "move_right")
	velocity.x = dir * SPEED
	if dir != 0:
		anim.flip_h = dir < 0
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
	play_anim("attack")

func handle_hurt() -> void:
	velocity.x = 0
	play_anim("hurt")

func handle_dead() -> void:
	velocity.x = 0
	play_anim("death")

func _on_animation_finished() -> void:
	match anim.animation:
		"attack":
			if current_state == State.ATTACK:
				change_state(State.IDLE if is_on_floor() else State.JUMP)
		"hurt":
			if current_state == State.HURT and not health.is_dead():
				change_state(State.IDLE if is_on_floor() else State.JUMP)
		"death":
			GameSession.go_to_fail_menu(get_tree())

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	if new_state == State.JUMP:
		velocity.y = JUMP_VELOCITY
	elif new_state == State.ATTACK:
		if attack_sfx != null:
			attack_sfx.play()

func play_anim(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)

func apply_enemy_hit(amount: int = 1) -> bool:
	if current_state == State.DEAD:
		return false

	var took_damage := health.apply_damage(amount)
	if not took_damage:
		return false

	if health.is_dead():
		_on_died()
	else:
		change_state(State.HURT)
		play_anim("hurt")

	return true

func restore_full_health() -> void:
	health.restore_full()

func get_health_component() -> PlayerHealth:
	return health

func _on_died() -> void:
	change_state(State.DEAD)
	play_anim("death")
