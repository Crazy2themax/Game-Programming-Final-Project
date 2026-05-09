extends CharacterBody2D

const SPEED = 150.0
@export var gravity: float = 400.0
const JUMP_VELOCITY = -300.0
const VICTORY_MENU_PATH = "res://Assets/scenes/VictoryMenu.tscn"

enum State { IDLE, RUN, ATTACK, JUMP, HURT, DEAD }

var current_state: State = State.IDLE
var dragon_slayer_active := false
var attack_targets_hit: Array[Node2D] = []
@onready var jump_sfx: AudioStreamPlayer2D = $jump
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_sfx: AudioStreamPlayer2D = $AttackSfx
@onready var health: PlayerHealth = $PlayerHealth
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_hitbox_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var potion_glow: PointLight2D = $PotionGlow

func _ready() -> void:
	add_to_group("player")
	anim.animation_finished.connect(_on_animation_finished)
	health.died.connect(_on_died)
	_set_attack_hitbox_enabled(false)
	_set_potion_visuals(false)
	_connect_dragon_died()
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	_update_attack_hitbox_position()
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
	_check_attack_hits()

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
				_set_attack_hitbox_enabled(false)
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
		if jump_sfx != null:
			jump_sfx.play()
	elif new_state == State.ATTACK:
		attack_targets_hit.clear()
		_set_attack_hitbox_enabled(true)
		if attack_sfx != null:
			attack_sfx.play()
	else:
		_set_attack_hitbox_enabled(false)

func play_anim(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)

func apply_enemy_hit(amount: int = 1, death_cause: String = "an enemy") -> bool:
	if current_state == State.DEAD:
		return false

	var took_damage := health.apply_damage(amount)
	if not took_damage:
		return false

	if health.is_dead():
		GameSession.set_death_cause(death_cause)
		_on_died()
	else:
		change_state(State.HURT)
		play_anim("hurt")

	return true

func restore_full_health() -> void:
	health.restore_full()

func get_health_component() -> PlayerHealth:
	return health

func activate_dragon_slayer_potion() -> void:
	dragon_slayer_active = true
	_set_potion_visuals(true)
	_connect_dragon_died()

func clear_dragon_slayer_potion() -> void:
	dragon_slayer_active = false
	_set_potion_visuals(false)

func has_dragon_slayer_potion() -> bool:
	return dragon_slayer_active

func _on_died() -> void:
	_set_attack_hitbox_enabled(false)
	change_state(State.DEAD)
	play_anim("death")

func _check_attack_hits() -> void:
	if attack_hitbox == null or not attack_hitbox.monitoring:
		return

	for body in attack_hitbox.get_overlapping_bodies():
		var target := body as Node2D
		if target == null or attack_targets_hit.has(target):
			continue
		attack_targets_hit.append(target)
		if target.has_method("apply_boss_hit"):
			var boss_damage := 2 if dragon_slayer_active else 1
			target.apply_boss_hit(boss_damage)

func _set_attack_hitbox_enabled(is_enabled: bool) -> void:
	if attack_hitbox == null or attack_hitbox_shape == null:
		return
	attack_hitbox.monitoring = is_enabled
	attack_hitbox_shape.disabled = not is_enabled
	if not is_enabled:
		attack_targets_hit.clear()

func _update_attack_hitbox_position() -> void:
	if attack_hitbox == null:
		return
	attack_hitbox.position.x = -18.0 if anim.flip_h else 18.0

func _set_potion_visuals(is_enabled: bool) -> void:
	if potion_glow != null:
		potion_glow.visible = is_enabled
	anim.modulate = Color(1.0, 0.88, 0.55, 1.0) if is_enabled else Color(1.0, 1.0, 1.0, 1.0)

func _on_dragon_died() -> void:
	clear_dragon_slayer_potion()
	var tree := get_tree()
	if tree == null:
		return
	await tree.create_timer(0.8).timeout
	tree.change_scene_to_file(VICTORY_MENU_PATH)

func _connect_dragon_died() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var dragon := tree.get_first_node_in_group("dragon_boss")
	if dragon == null or not dragon.has_signal("dragon_died"):
		return
	var dragon_died_callable := Callable(self, "_on_dragon_died")
	if not dragon.is_connected("dragon_died", dragon_died_callable):
		dragon.connect("dragon_died", dragon_died_callable)
