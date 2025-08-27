class_name Map
extends TileMapLayer

@export var fill_percent := 45
@export var smoothing_iterations := 4
@export var min_cave_size := 50
@export var room_radius := 4

@export var map_width := 10
@export var map_height := 10

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

func generate():
	start_point = Vector2i(1, 1)
	end_point = Vector2i(8, 8)

	var valid := false

	while not valid:
		clear()
		_map.clear()
		# seed(seed_value)

		_init_map()
		for i in smoothing_iterations:
			_smooth_map()

		_create_room(start_point, room_radius)
		_create_room(end_point, room_radius)

		_force_walls()

		_place_stairs()
		_apply_to_tilemap()
		_build_pathfinding()

		valid = _is_valid_map()

func _init_map():
	for x in range(map_width):
		for y in range(map_height):
			var pos := Vector2i(x, y)
			# Fill edges with walls
			if x == 0 || x == map_width - 1 || y == 0 || y == map_height - 1:
				_map[pos] = WALL_TILE
			else:
				_map[pos] = WALL_TILE if randf() * 100 < fill_percent else FLOOR_TILE

func _smooth_map() -> void:
	var new_map: Dictionary[Vector2i, int] = {}
	for x in range(map_width):
		for y in range(map_height):
			var pos := Vector2i(x, y)
			var wall_count := _get_surrounding_wall_count(pos)
			
			# Apply cellular automata rules
			if wall_count > 4:
				new_map[pos] = WALL_TILE
			elif wall_count < 4:
				new_map[pos] = FLOOR_TILE
			else:
				new_map[pos] = _map[pos]
	
	_map = new_map

func _get_surrounding_wall_count(pos: Vector2i) -> int:
	var wall_count := 0
	for x in range(-1, 2):
		for y in range(-1, 2):
			var check_pos := Vector2i(pos.x + x, pos.y + y)
			if check_pos != pos:
				if _map.get(check_pos, WALL_TILE) == WALL_TILE:  # Default to wall if outside bounds
					wall_count += 1
	return wall_count

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
	return not data or not data.get_custom_data("is_wall")

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
		pathfinding.add_point(id, cell)
		id += 1
	
	for i in pathfinding.get_point_ids():
		for j in pathfinding.get_point_ids():
			if i == j: continue
			if pathfinding.get_point_position(i).distance_to(pathfinding.get_point_position(j)) == 1:
				pathfinding.connect_points(i, j)
