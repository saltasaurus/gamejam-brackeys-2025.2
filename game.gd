extends Node2D

const ENEMY_GROUP = "enemy"

@onready var player = $Player
@onready var tilemap = $TileMapLayer

var tile_size = 10

func _ready() -> void:
	player.position = position.snapped(Vector2.ONE * tile_size)
	for e in (get_tree().get_nodes_in_group(ENEMY_GROUP) as Array[Node2D]):
		e.position = e.position.snapped(Vector2.ONE * tile_size)
	
func _unhandled_input(event):
	if event.is_action_pressed("move_left"):
		move_player(Vector2.LEFT)
	elif event.is_action_pressed("move_right"):
		move_player(Vector2.RIGHT)
	elif event.is_action_pressed("move_up"):
		move_player(Vector2.UP)
	elif event.is_action_pressed("move_down"):
		move_player(Vector2.DOWN)
	
func move_player(dir):
	if move_entity(player, dir):
		update_world()

func move_entity(e: Node2D, dir: Vector2) -> bool:
	var movement: Vector2 = dir * tile_size
	var next_position = e.position + movement
	var data: TileData = tilemap.get_cell_tile_data(tilemap.local_to_map(next_position))

	if not data or not data.get_custom_data("is_wall"):
		e.position = next_position
		return true

	return false

func update_world():
	var enemies = get_tree().get_nodes_in_group(ENEMY_GROUP)
	for e in enemies:
		var enemy = e as Enemy
		var action = enemy.take_action()
		if action != null:
			match action.type:
				EntityAction.Type.MOVE:
					move_entity(enemy, action.move_dir)
