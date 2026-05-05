extends CharacterBody2D

signal dragon_died

@export var fire_interval := 2.0

var fire_cooldown := 0.0
var is_dead := false

@onready var dragon_sprite: AnimatedSprite2D = $DragonAnimatedSprite
@onready var fireball_launch_point: Marker2D = get_node_or_null("DragonAnimatedSprite/FireballLaunchPoint") as Marker2D
@onready var fireball_template: Area2D = get_node_or_null("DragonAnimatedSprite/FireballLaunchPoint/Fireball") as Area2D
@onready var attack_sfx: AudioStreamPlayer2D = $AttackSfx
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var boss_health: PlayerHealth = $BossHealth
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("dragon_boss")
	if boss_health != null:
		boss_health.died.connect(_on_died)
	if fireball_template == null or fireball_launch_point == null:
		push_warning("Dragon fireball setup is incomplete. Check FireballLaunchPoint and Fireball nodes.")
		return
	fireball_template.call("configure", fireball_launch_point, self, Vector2.LEFT)

func _process(delta: float) -> void:
	if is_dead or fireball_template == null:
		return

	fire_cooldown -= delta
	if fire_cooldown > 0.0:
		return
	launch_fireball()
	fire_cooldown = fire_interval

func launch_fireball() -> void:
	if is_dead or fireball_template == null or fireball_launch_point == null:
		push_warning("Dragon fireball launch setup is incomplete. Check FireballLaunchPoint and Fireball nodes.")
		return
	var launch_parent := get_tree().current_scene
	if launch_parent == null:
		launch_parent = get_parent()
	if launch_parent == null:
		return

	var spawned_fireball := fireball_template.duplicate()
	launch_parent.add_child(spawned_fireball)
	spawned_fireball.call("configure", fireball_launch_point, self, Vector2.LEFT, true)
	dragon_sprite.play("attack")
	if attack_sfx != null:
		attack_sfx.play()
	spawned_fireball.call("launch")

func apply_boss_hit(amount: int = 1) -> bool:
	if boss_health == null or is_dead:
		return false

	var took_damage := boss_health.apply_damage(amount)
	if took_damage and boss_health.is_dead():
		_on_died()
	return took_damage

func get_health_component() -> PlayerHealth:
	return boss_health

func _on_died() -> void:
	if is_dead:
		return

	is_dead = true
	fire_cooldown = 0.0
	if attack_sfx != null and attack_sfx.playing:
		attack_sfx.stop()
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)
	if animation_player != null and animation_player.has_animation("boss_death"):
		animation_player.play("boss_death")
	else:
		dragon_sprite.play("death")
	dragon_died.emit()
