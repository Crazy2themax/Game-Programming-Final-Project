extends CanvasLayer


@onready var controls_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	_hide_controls_after_delay()


func _hide_controls_after_delay() -> void:
	await get_tree().create_timer(5.0).timeout
	controls_layer.hide()