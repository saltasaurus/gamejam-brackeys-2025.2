class_name Game
extends Node2D

const ENEMY_GROUP = "enemy"

@onready var player = $Player
@onready var tilemap: TileMapLayer = $TileMapLayer

var tile_size = 10
var pathfinding: AStar2D

func _ready() -> void:
	_build_pathfinding()
	
	_snap_entity_pos(player)
	for e in (get_tree().get_nodes_in_group(ENEMY_GROUP) as Array[Node2D]):
		_snap_entity_pos(e)

func _snap_entity_pos(e: Node2D) -> void:
	e.position = e.position.snapped(Vector2.ONE * tile_size)

func _build_pathfinding() -> void:
	pathfinding = AStar2D.new()
	var id = 0
	for cell in tilemap.get_used_cells():
		if not is_walkable(cell):
			continue
		pathfinding.add_point(id, cell)
		id += 1
	
	for i in pathfinding.get_point_ids():
		for j in pathfinding.get_point_ids():
			if i == j: continue
			if pathfinding.get_point_position(i).distance_to(pathfinding.get_point_position(j)) == 1:
				pathfinding.connect_points(i, j)
	
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

func is_walkable(cell_pos: Vector2i) -> bool:
	var data: TileData = tilemap.get_cell_tile_data(cell_pos)
	return not data or not data.get_custom_data("is_wall")

func pathfind(start_world_pos: Vector2, goal_world_pos: Vector2) -> PackedVector2Array:
	var start_id = pathfinding.get_closest_point(tilemap.local_to_map(start_world_pos))
	var goal_id = pathfinding.get_closest_point(tilemap.local_to_map(goal_world_pos))
	return pathfinding.get_point_path(start_id, goal_id)

func move_entity(e: Node2D, dir: Vector2) -> bool:
	var movement: Vector2 = dir * tile_size
	var next_position = e.position + movement

	if is_walkable(tilemap.local_to_map(next_position)):
		e.position = next_position
		return true

	return false

func update_world():
	var enemies = get_tree().get_nodes_in_group(ENEMY_GROUP)
	for e in enemies:
		var enemy = e as Enemy
		var action = enemy.take_action(self)
		if action != null:
			match action.type:
				EntityAction.Type.MOVE:
					move_entity(enemy, action.move_dir)
