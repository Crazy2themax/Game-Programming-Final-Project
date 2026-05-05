extends CharacterBody2D

@export var fire_interval := 2.0

var fire_cooldown := 0.0
var recovery_sound_played := false

@onready var dragon_sprite: AnimatedSprite2D = $DragonAnimatedSprite
@onready var fireball_launch_point: Marker2D = get_node_or_null("DragonAnimatedSprite/FireballLaunchPoint") as Marker2D
@onready var fireball = get_node_or_null("DragonAnimatedSprite/FireballLaunchPoint/Fireball")
@onready var attack_sfx: AudioStreamPlayer2D = $AttackSfx
@onready var recovery_roar_sfx: AudioStreamPlayer2D = $RecoveryRoarSfx

func _ready() -> void:
	if fireball == null or fireball_launch_point == null:
		push_warning("Dragon fireball setup is incomplete. Check FireballLaunchPoint and Fireball nodes.")
		return
	fireball.call("configure", fireball_launch_point, self, Vector2.LEFT)
	reset_fireball()

func _process(delta: float) -> void:
	if fireball == null:
		return

	fire_cooldown -= delta
	if fire_cooldown > 0.0:
		if not recovery_sound_played:
			play_recovery_roar()
			recovery_sound_played = true
		return
	if fireball.call("is_ready_to_launch"):
		launch_fireball()
		fire_cooldown = fire_interval
		recovery_sound_played = false

func reset_fireball() -> void:
	if fireball == null:
		push_warning("Dragon fireball node is missing. Check the scene node paths.")
		return
	fireball.call("reset_to_spawn")

func launch_fireball() -> void:
	if fireball == null or fireball_launch_point == null:
		push_warning("Dragon fireball launch setup is incomplete. Check FireballLaunchPoint and Fireball nodes.")
		return
	if recovery_roar_sfx != null and recovery_roar_sfx.playing:
		recovery_roar_sfx.stop()
	dragon_sprite.play("attack")
	if attack_sfx != null:
		attack_sfx.play()
	fireball.call("launch")

func play_recovery_roar() -> void:
	if recovery_roar_sfx == null:
		return
	if attack_sfx != null and attack_sfx.playing:
		return
	recovery_roar_sfx.play()
