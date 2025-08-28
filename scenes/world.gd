class_name World
extends SubViewport

const ENEMY_GROUP = "enemy"
const ENTITY_GROUP = "entity"

static var damage_indicator = preload("res://scenes/damage_indicator.tscn")
static var chest_scene = preload("res://entities/chest/Chest.tscn")

@onready var player = $Player
@onready var map: Map = $ProcMap
@onready var cards = $CardsCanvas/Cards
@onready var cards_canvas = $CardsCanvas
@onready var camera = $Camera

var tile_size = 10
var paused: bool = false
var player_floor = 1
var select_cards: bool = false

func _ready() -> void:
	setup_world()
	cards_canvas.visible = false
	gui_disable_input = false
	player.health_updated.connect(_on_player_health_updated)

	EventManager.entity_died.connect(_on_entity_died)

func _on_player_health_updated(health: int):
	EventManager.player_health_updated.emit(health)

func _on_entity_died(e: Entity):
	map.vacate(e.position)
	e.queue_free()

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

func on_chest_opened(item: Item):
	if item is HealthItem:
		player.heal(item.heal_amount)

func move_player(dir):
	var entity = get_adjacent_entity(player.position, dir)
	var _update_world = false
	if entity != null:
		if entity is Enemy:
			await attack_melee(player, entity, dir)
			_update_world = true
		if entity is Interactable:
			(entity as Interactable).interact(player)
			_update_world = true
	elif move_entity(player, dir):
		camera.position = player.position
		if on_stairs(player):
			load_next_level()
		else:
			_update_world = true

	if _update_world:
		paused = true
		await update_world()
		paused = false

func pathfind(start_world_pos: Vector2, goal_world_pos: Vector2) -> PackedVector2Array:
	var start_id = map.pathfinding.get_closest_point(map.local_to_map(start_world_pos))
	var goal_id = map.pathfinding.get_closest_point(map.local_to_map(goal_world_pos))
	return map.pathfinding.get_point_path(start_id, goal_id)

func get_adjacent_entity(pos: Vector2, dir: Vector2) -> Enemy:
	var movement: Vector2 = dir * tile_size
	var next_position = pos + movement
	return map.get_entity(next_position)

func get_adjacent_enemy(pos: Vector2, dir: Vector2) -> Enemy:
	var e = get_adjacent_entity(pos, dir)
	if e is Enemy:
		return e as Enemy
	return null

func get_adjacent_player_dir(pos: Vector2) -> Vector2:
	for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var e = get_adjacent_entity(pos, dir)
		if e is Player:
			return dir
	return Vector2.ZERO

func move_entity(entity: Node2D, dir: Vector2) -> bool:
	var movement: Vector2 = dir * tile_size
	var next_position = entity.position + movement
	
	if map.is_walkable(map.local_to_map(next_position)):
		map.occupy(next_position, entity)
		map.vacate(entity.position)
		entity.position = next_position
		return true

	return false

func on_stairs(e: Node2D) -> bool:
	return map.is_stairs(map.local_to_map(e.position))

func update_world():
	var enemies = get_tree().get_nodes_in_group(ENEMY_GROUP)

	for e in enemies:
		if not is_instance_valid(e):
			continue

		var enemy = e as Enemy
		if not enemy.is_alive():
			continue

		var action := enemy.take_action(self)
		if action == null:
			continue

		match action.type:
			EntityAction.Type.MOVE:
				move_entity(enemy, action.move_dir)
			EntityAction.Type.ATTACK_MELEE:
				var target_entity = map.get_entity(enemy.position + (action.attack_dir * tile_size))
				if target_entity != null:
					await get_tree().create_timer(0.1).timeout
					await attack_melee(enemy, target_entity, action.attack_dir)

func setup_world():
	# Hacky way to clear world between levels
	for e in get_children():
		if e is Chest:
			e.free()

	map.generate(1)

	for chest_pos in map.chests:
		var c = chest_scene.instantiate() as Chest
		# TODO: Random item
		c.item = load("res://items/basic_potion.tres")
		c.position = chest_pos * tile_size
		add_child(c)
		c.opened.connect(on_chest_opened)
		map.occupy(c.position, c)

	player.position = map.start_point * tile_size
	camera.position = player.position

	for e in (get_tree().get_nodes_in_group(ENTITY_GROUP) as Array[Node2D]):
		map.occupy(e.position, e)
		_snap_entity_pos(e)


func load_next_level():
	paused = true
	var transition: ColorRect = $EffectsCanvas/Transition

	await wait_for_transition(transition, 1, 1)

	# TODO: Real card selection logic
	select_cards = player_floor % 1 == 0

	if select_cards:
		cards_canvas.visible = true

		# TODO: Generate real cards
		var duration = randi_range(1, 3)

		var s1 = StatModifier.new()
		s1.type = StatModifier.Type.ADD
		s1.duration = duration
		s1.target = CharacterStats.Type.STRENGTH
		s1.value = randi_range(1, 5)
		
		var m1 = CardModifier.new()
		m1.duration_floors = duration
		m1.modifiers.push_back(s1)
		#m1.modifiers.push_back(s1)

		var modifiers: Array[CardModifier] = []
		modifiers.push_back(m1)
		modifiers.push_back(m1)
		modifiers.push_back(m1)

		cards.show_cards(modifiers)

		await wait_for_transition(transition, -1, 1)

		var card_modifier: CardModifier = await cards.selected
		
		# Only need to send Array[StatModifiers] bc duration is set above
		# Player updates stats by connecting to this signal
		EventManager.emit_signal("card_selected", card_modifier.modifiers)

		await wait_for_transition(transition, 1, 1)

	cards_canvas.visible = false
	setup_world()
	player_floor += 1
	# Tell UI to update
	EventManager.emit_signal("level_passed", player_floor)

	await wait_for_transition(transition, -1, 1)
	paused = false

func wait_for_transition(transition: ColorRect, final_val: Variant, duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(transition, "material:shader_parameter/height", final_val, duration)
	await tween.finished

func attack_melee(source: Entity, target: Entity, dir: Vector2) -> void:
	await source.play_melee_attack_anim(dir)
	var damage = source.stats.strength.adjustedValue - target.stats.defense.adjustedValue
	target.take_damage(damage)
	spawn_damage_indicator(damage, target.position + Vector2(4, -5))

func spawn_damage_indicator(val: int, pos: Vector2):
	var s: RogueStatusIndicator = damage_indicator.instantiate() as RogueStatusIndicator
	s.position = pos
	s.text = str(val)
	add_child(s)
