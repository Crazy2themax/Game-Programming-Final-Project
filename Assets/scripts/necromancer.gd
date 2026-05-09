extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var detection_zone = $DetectionZone
@onready var spell_spawn = $SpellSpawn

const SPELL_SCENE = preload("res://Assets/scenes/spell_attack.tscn")

var max_health = 2
var health = max_health
var is_dead = false
var is_hurt = false
var is_attacking = false
var player_in_range = false
var player_ref = null

var attack_timer = 0.0
const ATTACK_INTERVAL = 3.0

func _ready():
	anim.play("Idle")
	detection_zone.body_entered.connect(_on_body_entered)
	detection_zone.body_exited.connect(_on_body_exited)
	$HurtBox.body_entered.connect(_on_hurtbox_entered)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

	if is_dead or is_hurt:
		return

	if player_in_range and player_ref != null:
		if not _player_is_dead():
			face_player()
			if not is_attacking:
				attack_timer += delta
				if attack_timer >= ATTACK_INTERVAL:
					attack_timer = 0.0
					start_attack()
	else:
		attack_timer = 0.0
		anim.play("Idle")

func face_player():
	if player_ref == null:
		return
	anim.flip_h = player_ref.global_position.x < global_position.x

func start_attack():
	if is_dead or is_hurt or is_attacking:
		return
	is_attacking = true
	face_player()
	anim.play("Attack")
	await get_tree().create_timer(0.5).timeout
	shoot_all_directions()
	await anim.animation_finished
	is_attacking = false

func shoot_all_directions():
	if player_ref == null or _player_is_dead():
		return

	# 8 directions: right, left, up, down, and 4 diagonals
	var directions = [
		Vector2(1, 0),    # right
		Vector2(-1, 0),   # left
		Vector2(0, -1),   # up
		Vector2(0, 1),    # down
		Vector2(1, -1),   # up-right
		Vector2(-1, -1),  # up-left
		Vector2(1, 1),    # down-right
		Vector2(-1, 1),   # down-left
	]

	for dir in directions:
		var spell = SPELL_SCENE.instantiate()
		spell.global_position = spell_spawn.global_position
		spell.set_direction(dir.normalized())
		get_tree().current_scene.add_child(spell)

func _player_is_dead() -> bool:
	if player_ref == null:
		return true
	if player_ref.has_method("get_health_component"):
		return player_ref.get_health_component().is_dead()
	return false

func apply_boss_hit(amount: int = 1) -> void:
	take_damage(amount)

func take_damage(amount = 1):
	if is_dead or is_hurt:
		return
	health -= amount
	if health <= 0:
		die()
		return
	is_hurt = true
	anim.play("Hurt")
	await anim.animation_finished
	is_hurt = false
	anim.play("Idle")

func die():
	is_dead = true
	anim.play("Death")
	$CollisionShape2D.set_deferred("disabled", true)
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	await anim.animation_finished
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		anim.play("Idle")

func _on_hurtbox_entered(body):
	if body.is_in_group("player"):
		take_damage(1)
