class_name World
extends SubViewport

const ENEMY_GROUP = "enemy"

@onready var player = $Player
@onready var map: Map = $ProcMap

var tile_size = 10
var paused: bool = false

func _ready() -> void:
	load_next_level()

func _snap_entity_pos(e: Node2D) -> void:
	e.position = e.position.snapped(Vector2.ONE * tile_size)
	
func _unhandled_input(event):
	if paused:
		return
	
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
		if on_stairs(player):
			load_next_level()
		else:
			update_world()

func pathfind(start_world_pos: Vector2, goal_world_pos: Vector2) -> PackedVector2Array:
	var start_id = map.pathfinding.get_closest_point(map.local_to_map(start_world_pos))
	var goal_id = map.pathfinding.get_closest_point(map.local_to_map(goal_world_pos))
	return map.pathfinding.get_point_path(start_id, goal_id)

func move_entity(e: Node2D, dir: Vector2) -> bool:
	var movement: Vector2 = dir * tile_size
	var next_position = e.position + movement

	if map.is_walkable(map.local_to_map(next_position)):
		e.position = next_position
		return true

	return false

func on_stairs(e: Node2D) -> bool:
	return map.is_stairs(map.local_to_map(e.position))

func update_world():
	var enemies = get_tree().get_nodes_in_group(ENEMY_GROUP)
	for e in enemies:
		var enemy = e as Enemy
		var action = enemy.take_action(self)
		if action != null:
			match action.type:
				EntityAction.Type.MOVE:
					move_entity(enemy, action.move_dir)

func load_next_level():
	paused = true
	var transition: ColorRect = $EffectsCanvas/Transition

	var tween = get_tree().create_tween()
	tween.tween_property(transition, "material:shader_parameter/height", 1, 1)
	await tween.finished
	
	map.generate()
	player.position = map.start_point * tile_size
	_snap_entity_pos(player)
	for e in (get_tree().get_nodes_in_group(ENEMY_GROUP) as Array[Node2D]):
		_snap_entity_pos(e)

	tween = get_tree().create_tween()
	tween.tween_property(transition, "material:shader_parameter/height", -1, 1)
	await tween.finished
	paused = false
