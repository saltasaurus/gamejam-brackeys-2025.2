class_name World
extends SubViewport

#region Variables

const ENEMY_GROUP = "enemy"
const ENTITY_GROUP = "entity"

@export var chest_items: Array[Item]
@export var modifiers: Array[StatModifier]

static var DEFAULT_ITEM = load("res://items/basic_potion.tres")
static var damage_indicator = preload("res://scenes/damage_indicator.tscn")
static var chest_scene = preload("res://entities/chest/Chest.tscn")
static var basic_enemy_scene = preload("res://entities/basic_enemy/basic_enemy.tscn")

@onready var player = $Player
@onready var map: Map = $ProcMap
@onready var cards = $CardsCanvas/Cards
@onready var cards_canvas = $CardsCanvas
@onready var death_canvas = $DeathCanvas
@onready var camera = $Camera
@onready var transition: ColorRect = $EffectsCanvas/Transition

var tile_size = 10
var paused: bool = false
var player_dead: bool = false
var player_floor: int = 1
var select_cards: bool = false

#region Difficulty variables
var num_chests = 1
var num_enemies = 2
var enemy_bonus_stats_count = 5
#endregion

var camera_follow_enabled: bool = true
#endregion

func _ready() -> void:
	setup_world()
	cards_canvas.visible = false
	gui_disable_input = false
	player.health_updated.connect(_on_player_health_updated)
	EventManager.entity_died.connect(_on_entity_died)

func _snap_entity_pos(e: Node2D) -> void:
	e.position = e.position.snapped(Vector2.ONE * tile_size)
	
func _unhandled_input(event):
	if player_dead:
		if event.is_action_pressed("ui_accept"):
			_restart()
		return

	if paused or player_dead:
		return

	paused = true
	var _update_world = false
	if event.is_action_pressed("move_left"):
		_update_world = await move_player(Vector2.LEFT)
	elif event.is_action_pressed("move_right"):
		_update_world = await move_player(Vector2.RIGHT)
	elif event.is_action_pressed("move_up"):
		_update_world = await move_player(Vector2.UP)
	elif event.is_action_pressed("move_down"):
		_update_world = await move_player(Vector2.DOWN)

	if _update_world:
		await update_world()
	paused = false

func _process(_delta: float) -> void:
	if camera_follow_enabled:
		camera.position = player.position
		
#region Signals
func _on_player_health_updated(health: int):
	# Is this circular?
	EventManager.player_health_updated.emit(health)

func _on_entity_died(e: Entity):
	if e is Player:
		_on_player_died()
	else:
		map.vacate(e.position)
		e.queue_free()
	
func on_chest_opened(item: Item):
	if item is HealthItem:
		player.heal(item.heal_amount)
	EventManager.emit_signal("player_stat_modified", item)
	print("SENT ITEM DATA")
#endregion

#region Entity movement
func move_player(dir) -> bool:
	var entity = get_adjacent_entity(player.position, dir)
	var _update_world = false
	player.face_direction(dir) # Want to face direction for walking AND attacking
	if entity != null:
		if entity is Enemy:
			camera_follow_enabled = false
			await attack_melee(player, entity, dir)
			camera_follow_enabled = true
			_update_world = true
		if entity is Interactable:
			(entity as Interactable).interact(player)
			_update_world = true
	elif await move_entity(player, dir):
		if on_stairs(player):
			await load_next_level()
		else:
			_update_world = true

	return _update_world
	
func move_entity(entity: Entity, dir: Vector2) -> bool:
	var movement: Vector2 = dir * tile_size
	var next_position = entity.position + movement
	
	if map.is_walkable(map.local_to_map(next_position)):
		map.vacate(entity.position)
		map.occupy(next_position, entity)

		if entity.on_screen.is_on_screen():
			var tween = get_tree().create_tween()
			tween.tween_property(entity, "position", next_position, 0.05)
			await tween.finished
		else:
			entity.position = next_position

		return true

	return false
#endregion

#region Map queries
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



func on_stairs(e: Node2D) -> bool:
	return map.is_stairs(map.local_to_map(e.position))
#endregion


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
				await move_entity(enemy, action.move_dir)
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
		elif e is Enemy:
			e.free()

	var num_entities = (player_floor / 3) + 1
	var num_chests = (player_floor / 10)
	var width = 10 + (player_floor / 3) + randi_range(0, 5)
	var height = 10 + (player_floor / 3) + randi_range(0, 5)

	map.generate(
		num_chests,
		num_entities,
		width,
		height,
	)

	# THIS SHOULD STAY HERE
	player.position = map.start_point * tile_size
	camera.position = player.position

	_create_and_place_chests()
	_create_and_place_enemies()
	_create_and_place_entities()


func _create_and_place_chests() -> void:
	for cell in map.chests:
		var c = chest_scene.instantiate() as Chest
		# TODO: Random item
		var item: Item = chest_items.pick_random()
		if item == null:
			item = DEFAULT_ITEM
		c.item = item
		c.position = cell * tile_size
		add_child(c)
		c.opened.connect(on_chest_opened)
		map.occupy(c.position, c)

func _create_and_place_enemies() -> void:
	for cell in map.enemies:
		var e = basic_enemy_scene.instantiate() as Enemy
		e.stats = _get_enemy_stats(e.stats)
		e.position = cell * tile_size
		add_child(e)
		map.occupy(e.position, e)
		
func _get_enemy_stats(current_stats: CharacterStats) -> CharacterStats:
	# For each bonus stat count, create a random stat modification
	for i in range(enemy_bonus_stats_count):
		var stat_mod = StatModifier.new() 
		var random_char_stat = randi_range(0, len(CharacterStats.Type) - 1)
		stat_mod.initialize(1, StatModifier.Type.ADD, random_char_stat)

	return current_stats

func _create_and_place_entities() -> void:
	for e in (get_tree().get_nodes_in_group(ENTITY_GROUP) as Array[Node2D]):
		_snap_entity_pos(e)
		map.occupy(e.position, e)

func create_card_stats(duration: int) -> StatModifier:
	var s1 = StatModifier.new()
	s1.initialize(randi_range(1, 5), StatModifier.Type.ADD, CharacterStats.Type.STRENGTH, duration)
	return s1

func create_card() -> CardModifier:
	var duration = randi_range(1, 3)
	var card = CardModifier.new()
	card.duration_floors = duration
	
	for i in range(1):
		var card_stats = create_card_stats(duration)
		card.modifiers.push_back(card_stats)
	
	return card

func load_next_level():
	paused = true

	await wait_for_transition(transition, 1, 1)

	# TODO: Real card selection logic
	select_cards = player_floor % 1 == 0

	if select_cards:
		cards_canvas.visible = true
	
		var modifiers: Array[CardModifier] = []
		for i in range(3):
			var cardmod = create_card()
			modifiers.push_back(cardmod)
			
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

func _on_player_died():
	paused = true
	player.die()
	player_dead = true
	await get_tree().create_timer(0.5).timeout
	await wait_for_transition(transition, 1, 1)
	death_canvas.visible = true
	await wait_for_transition(transition, -1, 1)

func _restart():
	print("Restarting")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
