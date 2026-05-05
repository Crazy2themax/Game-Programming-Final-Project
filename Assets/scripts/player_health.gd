extends Node
class_name PlayerHealth

signal health_changed(current_health: int, max_health: int)
signal died
signal restored_full

@export_range(1, 10, 1) var max_health := 4
@export_range(0.1, 3.0, 0.05) var invulnerability_duration := 0.75

var current_health := 0

@onready var invulnerability_timer: Timer = $InvulnerabilityTimer

func _ready() -> void:
	current_health = max_health
	invulnerability_timer.wait_time = invulnerability_duration
	health_changed.emit(current_health, max_health)

func apply_damage(amount: int = 1) -> bool:
	if amount <= 0 or is_dead() or is_invulnerable():
		return false

	current_health = maxi(current_health - amount, 0)
	invulnerability_timer.start(invulnerability_duration)
	health_changed.emit(current_health, max_health)

	if current_health == 0:
		died.emit()

	return true

func restore_full() -> void:
	if current_health == max_health and not is_dead():
		return

	current_health = max_health
	invulnerability_timer.stop()
	health_changed.emit(current_health, max_health)
	restored_full.emit()

func reset_health() -> void:
	current_health = max_health
	invulnerability_timer.stop()
	health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0

func is_invulnerable() -> bool:
	return not invulnerability_timer.is_stopped()

func get_health_ratio() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)