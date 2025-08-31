extends Node2D

@onready var frame_buffer := $FrameBuffer

@onready var transition: ColorRect = $SubViewport/Transition

const INTERNAL_RESOLUTION = Vector2i(320, 180)

var game_scale = 1

var transitioning_scenes := false

func _ready() -> void:
	_update_scale()
	get_viewport().size_changed.connect( _update_scale)

func _update_scale():
	var window_size = get_viewport().size
	game_scale = min(
		floor(window_size.x / INTERNAL_RESOLUTION.x),
		floor(window_size.y / INTERNAL_RESOLUTION.y)
	)
	if game_scale < 1:
		game_scale = 1
	
	var new_size = INTERNAL_RESOLUTION * game_scale
	frame_buffer.size = new_size
	frame_buffer.position = (window_size - new_size) / 2

func _unhandled_input(event: InputEvent) -> void:
	if transitioning_scenes:
		return

	if event.is_action_pressed("ui_accept"):
		transitioning_scenes = true
		await show_transition(1)
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func show_transition(duration: float) -> void:
	await wait_for_transition(1, duration)

func hide_transition(duration: float):
	await wait_for_transition(-1, duration)

func wait_for_transition(final_val: Variant, duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(transition, "material:shader_parameter/height", final_val, duration)
	await tween.finished
