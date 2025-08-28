class_name Game
extends Node2D

@onready var world = $World
@onready var ui: UI = $UIViewport/UI
@onready var frame_buffer := $FrameBuffer

const INTERNAL_RESOLUTION = Vector2i(320, 180)

var game_scale = 1

func _ready() -> void:
	_update_scale()
	get_viewport().connect("size_changed", _update_scale)
	ui.world = world

	frame_buffer.gui_input.connect(_on_frame_buffer_gui_input)

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

func _unhandled_input(event):
	if event is InputEventMouse:
		return
	world.push_input(event)

func _on_frame_buffer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		# Because we are rendering a viewport that is scaled up, we
		# must transform mouse events from screen pos to viewport pos.
		var local_pos = event.position / game_scale
		var ev = event.duplicate()
		ev.position = local_pos
		ev.global_position = local_pos
		world.push_input(ev)
	else:
		world.push_input(event)
