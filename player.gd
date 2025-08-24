extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var tile_size = 10

func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size)
	
func _unhandled_input(event):
	if event.is_action_pressed("move_left"):
		sprite.flip_h = true
		move(Vector2.LEFT)
	elif event.is_action_pressed("move_right"):
		move(Vector2.RIGHT)
		sprite.flip_h = false
	elif event.is_action_pressed("move_up"):
		move(Vector2.UP)
	elif event.is_action_pressed("move_down"):
		move(Vector2.DOWN)
	
func move(dir):
	position += dir * tile_size
	
	
