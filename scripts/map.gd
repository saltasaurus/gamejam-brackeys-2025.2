class_name Map
extends TileMapLayer

@export var fill_percent := 45
@export var smoothing_iterations := 4
@export var min_cave_size := 50
@export var room_radius := 2

var map_width := 10
var map_height := 10

const WALL_TILE := 0
const FLOOR_TILE := 1
const STAIRS_TILE := 2

const WALL_TILESET_POS := Vector2i(0, 0)
const FLOOR_TILESET_POS := Vector2i(1, 0)
const STAIRS_TILESET_POS := Vector2i(2, 0)

var _map: Dictionary[Vector2i, int] = {}
var start_point: Vector2i
var end_point: Vector2i

var pathfinding: AStar2D

var occupied: Dictionary[Vector2i, Node2D] = {}

var chests: Array[Vector2i] = []
var enemies: Array[Vector2i] = []

var free_cells: Dictionary[Vector2i, bool]
var free_dead_end_cells: Dictionary[Vector2i, bool]

func rand_pos() -> Vector2i:
	return Vector2i(randi_range(1, map_width - 2), randi_range(1, map_height - 2))

func generate(num_chests: int, num_enemies: int, width: int, height: int):
	map_width = width + 2
	map_height = height + 2
	start_point = rand_pos()
	end_point = rand_pos()

	clear()
	_map.clear()
	chests.clear()
	occupied.clear()
	enemies.clear()
	free_cells.clear()
	free_dead_end_cells.clear()

	generate_maze()

	_create_room(start_point, room_radius)
	_create_room(end_point, room_radius)

	_force_walls()
	_place_stairs()

	_apply_to_tilemap()

	free_dead_end_cells = _find_dead_ends()
	for cell in get_used_cells():
		if _map[cell] == FLOOR_TILE and cell != start_point and cell != end_point:
			free_cells[cell] = true

	chests = _place_random(num_chests, free_dead_end_cells)
	enemies = _place_random(num_enemies, free_cells)

	_build_pathfinding()
	
func generate_maze():
	for x in range(map_width):
		for y in range(map_height):
			_map[Vector2i(x, y)] = WALL_TILE

	carve(Vector2i(2, 2))

func carve(pos: Vector2i):
	_map[pos] = FLOOR_TILE

	var directions = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
	]
	directions.shuffle()

	for dir in directions:
		var next_pos = pos + (2 * dir)
		if _is_in_maze_bounds(next_pos) and _map[next_pos] == WALL_TILE:
			var wall_pos = pos + dir
			_map[wall_pos] = FLOOR_TILE
			carve(next_pos)

func _is_in_maze_bounds(pos: Vector2i) -> bool:
	# In bounds for the generated map which is actually smaller than the full map
	# Need to have a border of wall around the map, which takes one cell on each side.
	return pos.x > 1 and pos.x < map_width - 1 and pos.y > 1 and pos.y < map_height - 1

func _find_dead_ends() -> Dictionary[Vector2i, bool]:
	var dead_ends: Dictionary[Vector2i, bool] = {}
	for pos in _map.keys():
		if _map[pos] == FLOOR_TILE:
			var neighbors = 0
			var directions = [
				Vector2i.UP,
				Vector2i.DOWN,
				Vector2i.LEFT,
				Vector2i.RIGHT,
			]
			for dir in directions:
				if _map.has(pos + dir) and _map[pos + dir] == FLOOR_TILE:
					neighbors += 1
			if neighbors == 1:
				dead_ends[pos] = true
	return dead_ends

func _create_room(center: Vector2i, radius: int) -> void:
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var pos := Vector2i(center.x + x, center.y + y)
			if pos.x >= 0 && pos.x < map_width && pos.y >= 0 && pos.y < map_height:
				if Vector2i(x, y).length() <= radius:
					_map[pos] = FLOOR_TILE

func _force_walls() -> void:
	# Create walls on top and bottom edges
	for x in range(map_width):
		_map[Vector2i(x, 0)] = WALL_TILE              # Top wall
		_map[Vector2i(x, map_height - 1)] = WALL_TILE # Bottom wall
	
	# Create walls on left and right edges
	for y in range(map_height):
		_map[Vector2i(0, y)] = WALL_TILE              # Left wall
		_map[Vector2i(map_width - 1, y)] = WALL_TILE  # Right wall

func _place_stairs() -> void:
	_map[end_point] = STAIRS_TILE

func _get_tilemap_pos(tile) -> Vector2i:
	match tile:
		WALL_TILE:
			return WALL_TILESET_POS
		FLOOR_TILE:
			return FLOOR_TILESET_POS
		STAIRS_TILE:
			return STAIRS_TILESET_POS
	return FLOOR_TILESET_POS
		
func _apply_to_tilemap() -> void:
	for x in range(map_width):
		for y in range(map_height):
			var pos := Vector2i(x, y)
			if _map.has(pos):
				set_cell(pos, 0, _get_tilemap_pos(_map[pos]), 0)
			else:
				set_cell(pos, 0, FLOOR_TILESET_POS, 0)

func is_walkable(cell_pos: Vector2i) -> bool:
	var data: TileData = get_cell_tile_data(cell_pos)
	var is_wall = data != null and data.get_custom_data("is_wall")
	return get_entity_at_cell(cell_pos) == null and not is_wall

func is_stairs(cell_pos: Vector2i) -> bool:
	var data: TileData = get_cell_tile_data(cell_pos)
	return data and data.get_custom_data("is_stairs")

func _is_valid_map() -> bool:
	var start_id = pathfinding.get_closest_point(start_point)
	var goal_id = pathfinding.get_closest_point(end_point)
	return pathfinding.get_point_path(start_id, goal_id).size() > 0

func _build_pathfinding() -> void:
	pathfinding = AStar2D.new()
	var id = 0
	for cell in get_used_cells():
		if not is_walkable(cell):
			continue
		if cell in chests:
			continue
		if cell == end_point:
			continue
		pathfinding.add_point(id, cell)
		id += 1
	
	for i in pathfinding.get_point_ids():
		for j in pathfinding.get_point_ids():
			if i == j: continue
			if pathfinding.get_point_position(i).distance_to(pathfinding.get_point_position(j)) == 1:
				pathfinding.connect_points(i, j)

func _place_random(num: int, source: Dictionary[Vector2i, bool]) -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	for i in range(num):
		if source.size() == 0:
			break 

		var idx = randi_range(0, source.size() - 1)
		var pos = source.keys()[idx]
		res.push_back(pos)

		# Erase from all cell tracking containers
		free_cells.erase(pos)
		free_dead_end_cells.erase(pos)

	return res

func occupy(pos: Vector2, entity: Node2D) -> void:
	occupied[local_to_map(pos)] = entity

func vacate(pos: Vector2) -> void:
	occupied.erase(local_to_map(pos))

func get_entity(pos: Vector2) -> Node:
	return occupied.get(local_to_map(pos), null)

func get_entity_at_cell(cell: Vector2i) -> Node:
	return occupied.get(cell, null)
