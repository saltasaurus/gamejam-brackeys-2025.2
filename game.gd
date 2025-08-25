extends Node2D

@onready var player = $Player
@onready var tilemap = $TileMapLayer

var tile_size = 10

func _ready() -> void:
	player.position = position.snapped(Vector2.ONE * tile_size)
	
func _unhandled_input(event):
	if event.is_action_pressed("move_left"):
		move(Vector2.LEFT)
	elif event.is_action_pressed("move_right"):
		move(Vector2.RIGHT)
	elif event.is_action_pressed("move_up"):
		move(Vector2.UP)
	elif event.is_action_pressed("move_down"):
		move(Vector2.DOWN)
	
func move(dir):
	var movement: Vector2 = dir * tile_size
	var next_position = player.position + movement
	var data: TileData = tilemap.get_cell_tile_data(tilemap.local_to_map(next_position))
	var is_wall = false
	if data:
		is_wall = data.get_custom_data("is_wall")
	if not is_wall:
		player.position += dir * tile_size
