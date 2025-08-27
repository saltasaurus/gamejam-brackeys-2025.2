class_name Game
extends Node2D

@onready var world_viewport = $World
@onready var frame_buffer := $FrameBuffer

const INTERNAL_RESOLUTION = Vector2i(160, 90)

func _ready() -> void:
    _update_scale()
    get_viewport().connect("size_changed", _update_scale)

func _update_scale():
    var window_size = get_viewport().size
    var game_scale = min(
        floor(window_size.x / INTERNAL_RESOLUTION.x),
        floor(window_size.y / INTERNAL_RESOLUTION.y)
    )
    if game_scale < 1:
        game_scale = 1
    
    var new_size = INTERNAL_RESOLUTION * game_scale
    frame_buffer.size = new_size
    frame_buffer.position = (window_size - new_size) / 2

func _unhandled_input(event):
    world_viewport.push_input(event)