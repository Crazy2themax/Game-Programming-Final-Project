extends CharacterBody2D


const ANIMATION_DATA := {
	"attack": {
		"texture": preload("res://Assets/character-animation-extended/ATTACK-(horizontal=6,vertical=1).png"),
		"frames": 6,
		"fps": 12.0,
		"loop": false,
	},
	"death": {
		"texture": preload("res://Assets/character-animation-extended/DEATH-(horizontal=12,vertical=1).png"),
		"frames": 12,
		"fps": 10.0,
		"loop": false,
	},
	"hurt": {
		"texture": preload("res://Assets/character-animation-extended/HURT-(horizontal=4,vertical=1).png"),
		"frames": 4,
		"fps": 10.0,
		"loop": false,
	},
	"idle": {
		"texture": preload("res://Assets/character-animation-extended/IDLE(horizontal=7,vertical=1).png"),
		"frames": 7,
		"fps": 8.0,
		"loop": true,
	},
	"jump": {
		"texture": preload("res://Assets/character-animation-extended/JUMP(horizontal=5,vertical=1).png"),
		"frames": 5,
		"fps": 8.0,
		"loop": false,
	},
	"run": {
		"texture": preload("res://Assets/character-animation-extended/RUN-WALK(horizontal=8,vertical=1).png"),
		"frames": 8,
		"fps": 10.0,
		"loop": true,
	},
}

enum PlayerState { IDLE, RUN, JUMP, ATTACK, HURT, DEATH }

@export var move_speed := 220.0
@export var jump_velocity := -420.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

var state := PlayerState.IDLE


func _ready() -> void:
	_build_animations()
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


func _build_animations() -> void:
	var frames_resource := SpriteFrames.new()

	for animation_name in ANIMATION_DATA:
		var animation: Dictionary = ANIMATION_DATA[animation_name]
		var texture := animation["texture"] as Texture2D
		var frame_count: int = animation["frames"]
		var frame_width := texture.get_width() / frame_count
		var frame_height := texture.get_height()

		frames_resource.add_animation(animation_name)
		frames_resource.set_animation_speed(animation_name, animation["fps"])
		frames_resource.set_animation_loop(animation_name, animation["loop"])

		for frame_index in range(frame_count):
			var atlas_texture := AtlasTexture.new()
			atlas_texture.atlas = texture
			atlas_texture.region = Rect2(frame_index * frame_width, 0, frame_width, frame_height)
			frames_resource.add_frame(animation_name, atlas_texture)

	animated_sprite.sprite_frames = frames_resource


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
