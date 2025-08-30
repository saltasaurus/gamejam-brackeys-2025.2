class_name World
extends SubViewport

#region Variables

const ENEMY_GROUP = "enemy"
const ENTITY_GROUP = "entity"

const ENTITY_ACTION_DELAY = 0.1

@export var chest_items: Array[Item]
@export var player_floor: int = 1
#@export var modifiers: Array[StatModifier]

static var DEFAULT_ITEM = load("res://items/basic_potion.tres")
static var damage_indicator = preload("res://scenes/damage_indicator.tscn")
static var chest_scene = preload("res://entities/chest/Chest.tscn")
static var basic_enemy_scene = preload("res://entities/basic_enemy/basic_enemy.tscn")

@onready var player = $Player
@onready var map: Map = $ProcMap
@onready var cards = $CardsCanvas/VBoxContainer/Cards
@onready var level_transition_phrase = $CardsCanvas/VBoxContainer/Phrase
@onready var cards_canvas = $CardsCanvas
@onready var death_canvas = $DeathCanvas
@onready var camera = $Camera
@onready var transition: ColorRect = $EffectsCanvas/Transition
@onready var EnemySpawner: WeightRandom = $EnemySpawner

var tile_size = 10
var paused: bool = false
var player_dead: bool = false
var select_cards: bool = false
var can_restart: bool = false

#region Difficulty variables
var num_chests = 0
var num_enemies = 0:
	set(new_value):
		num_enemies = max(1, new_value)
var enemy_bonus_stats_count = 5
#endregion

var camera_follow_enabled: bool = true
#endregion

const PHRASES = [
	"Pick your plate",
	"You're in a pickle now",
	"PO-TA-TOES",
	"This is getting spicy",
	"Risk it for the biscuit",
	"Eggscuse me",
	"Batter up",
	"There's a lot at steak here",
	"Lettuce play a game",
	"Anyone can cook!",
	"One can get too familiar with vegetables, you know",
	"The soup! Where is the soup?",
	"Don't get whisked away",
	"Oh honey",
	"You are cooking",
	"Working hard or hardly working",
	"An apple a day",
	"You're toast out there",
	"Both the bread and le pain",
	"Creme de la creme"
]

func _ready() -> void:
	setup_world()
	cards_canvas.visible = false
	gui_disable_input = false
	player.health_updated.connect(_on_player_health_updated)
	EventManager.entity_died.connect(_on_entity_died)
	EventManager.card_selected.connect(_on_card_selected)
	

func _snap_entity_pos(e: Node2D) -> void:
	e.position = e.position.snapped(Vector2.ONE * tile_size)
	
func _unhandled_input(event):
	if event.is_action_pressed("debug"):
		player.take_damage(100)
		return

	if can_restart:
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
	
func _on_card_selected(card: CardModifier):
	print("CARD ENEMY COUNT: ", card.enemy_count)
	if card.enemy_count == null:
		return
	num_enemies += card.enemy_count
	print("NUMBER ENEMIES: ", num_enemies)
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
				move_entity(enemy, action.move_dir)
			EntityAction.Type.ATTACK_MELEE:
				var target_entity = map.get_entity(enemy.position + (action.attack_dir * tile_size))
				if target_entity != null:
					await get_tree().create_timer(ENTITY_ACTION_DELAY).timeout
					await attack_melee(enemy, target_entity, action.attack_dir)

	await get_tree().create_timer(ENTITY_ACTION_DELAY).timeout

func setup_world():
	for e in get_children():
		if e is Chest:
			e.free()
		elif e is Enemy:
			e.free()

	if player_floor % 5 == 4: # Every 5 rounds, skipping the first
		EnemySpawner.update_weights()

	var width = 6 + (player_floor / 2)
	var height = 6 + (player_floor / 2)
	
	var total_enemies: int = num_enemies + (player_floor / 3) + 1
	var total_chests: int = num_chests + (player_floor / 10) + 1
	map.generate(
		total_chests,
		total_enemies,
		width,
		height,
	)
	
	

	# THIS SHOULD STAY HERE
	# OTHERWISE _create_and_place_entities WILL OPERATE ON AN
	# OLD VERSION OF THE PLAYER POSITION
	player.position = map.start_point * tile_size
	camera.position = player.position

	_create_and_place_chests()
	_create_and_place_enemies()
	_create_and_place_entities()



func _create_and_place_chests() -> void:
	for cell in map.chests:
		var c = chest_scene.instantiate() as Chest
		var item: Item = chest_items.pick_random()
		if item == null:
			item = DEFAULT_ITEM
		c.item = item
		c.position = cell * tile_size
		add_child(c)
		c.opened.connect(on_chest_opened)
		map.occupy(c.position, c)

func _create_and_place_enemies() -> void:
	#var enemy_list: Array = [basic_enemy_scene]
	#var spawn_weights: Array[float] = [1.0]
	for cell in map.enemies:
		var picked_enemy = EnemySpawner.pick_object()
		var e = picked_enemy.instantiate() as Enemy
		#var e = basic_enemy_scene.instantiate() as Enemy
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
	s1.initialize(randi_range(1, 3), StatModifier.Type.ADD, CharacterStats.Type.STRENGTH)
	return s1

func create_card() -> CardModifier:
	#var duration = randi_range(1, 3)
	var duration = 0
	var card = CardModifier.new()
	card.duration_floors = duration
	card.enemy_count = 1
	
	for i in range(1):
		var card_stats = create_card_stats(duration)
		card.modifiers.push_back(card_stats)
	
	
	return card


func load_next_level():
	paused = true

	await show_transition(1)

	# TODO: Real card selection logic
	select_cards = player_floor % 1 == 0
	print("SELECT CARDS: ", select_cards)

	if select_cards:
		cards_canvas.visible = true
	
		var modifiers: Array[CardModifier] = []
		for i in range(3):
			var cardmod: CardModifier = create_card()
			modifiers.push_back(cardmod)
			
		cards.show_cards(modifiers)
		level_transition_phrase.text = PHRASES.pick_random() + "..."

		await hide_transition(1)

		var card_modifier: CardModifier = await cards.selected
		print("Card selected: ", card_modifier.modifiers)
		# Only need to send Array[StatModifiers] bc duration is set above
		# Player updates stats by connecting to this signal
		EventManager.emit_signal("card_selected", card_modifier)

		await show_transition(1)

	cards_canvas.visible = false
	setup_world()
	player_floor += 1
	# Tell UI to update
	EventManager.emit_signal("level_passed", player_floor)

	await hide_transition(1)
	paused = false

func show_transition(duration: float) -> void:
	await wait_for_transition(1, duration)

func hide_transition(duration: float):
	await wait_for_transition(-1, duration)

func wait_for_transition(final_val: Variant, duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(transition, "material:shader_parameter/height", final_val, duration)
	await tween.finished

func attack_melee(source: Entity, target: Entity, dir: Vector2) -> void:
	await source.play_melee_attack_anim(dir)
	var damage = source.stats.strength.adjustedValue - target.stats.defense.adjustedValue
	if damage < 0:
		damage = 0
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
	await show_transition(1)
	death_canvas.visible = true
	await hide_transition(1)
	can_restart = true

func _restart():
	print("Restarting")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
