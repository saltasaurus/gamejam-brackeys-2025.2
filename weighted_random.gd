class_name WeightRandom
extends Node

## All enemies within the game. Ordered by difficulty
@export var enemy_list: Array[PackedScene]
## A subset of all possible enemies
var _enemy_list: Array[PackedScene] = []
## The current enemies available to add
var _current_enemies: Array[PackedScene] = []

var spawn_weights: Array[float]
var RNG: RandomNumberGenerator

func _ready() -> void:
	RNG = RandomNumberGenerator.new()
	_enemy_list = enemy_list.duplicate()
	# First enemy should always be the easiest in editor
	_current_enemies.append(_enemy_list.pop_front())
	# Once first enemy removed, then shuffle harder enemies
	_enemy_list.shuffle()
	
func generate_normal_weights(length: int) -> Array:
	var weights = []
	if length <= 0:
		return weights
	
	var sigma = length / 6.0  # Controls the spread; adjust as needed
	var center = (length - 1) / 2.0
	
	for i in range(length):
		var x = i - center
		var weight = exp(-pow(x, 2) / (2 * pow(sigma, 2)))
		weights.append(weight)
	
	# Optional: Normalize so the peak is 1
	var max_weight = weights.max()
	for i in range(length):
		weights[i] /= max_weight
	
	return weights

func pick_object() -> PackedScene:
	if _current_enemies.is_empty():
		push_error("Current enemies is empty!?")
	
	#var current_weights = generate_normal_weights(len(_current_enemies))
	#var random_enemy: int = RNG.rand_weighted(current_weights)
	return _current_enemies.pick_random()

## Add next iteration of enemies to spawnable pool
func add_enemy() -> void:
	print("Adding new enemies")
	if _enemy_list.is_empty():
		_enemy_list = enemy_list.duplicate()
		_enemy_list.shuffle()
	
	_current_enemies.append(_enemy_list.pop_front())
