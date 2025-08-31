class_name WeightRandom
extends Node

@export var enemy_list: Array[PackedScene]
@export var spawn_weights: Array[float]

var total: float = 0.0
var acc_weights: Array[float] = []

func _ready() -> void:
	init_probabilities(spawn_weights)

func init_probabilities(_weights: Array[float]) -> void:
	acc_weights = []
	for weight in spawn_weights:
		total += weight
		acc_weights.append(total)
		
func pick_object() -> PackedScene:
	var roll: float = randf_range(0.0, total)
	for i in range(len(acc_weights)):
		if acc_weights[i] > roll:
			return enemy_list[i]
	return enemy_list[0]
	
func add_enemy(enemy: PackedScene) -> void:
	#enemy_list
	pass

func update_weights() -> void:
	if len(spawn_weights) <= 1:
		return
		
	spawn_weights[0] += 0.1
	init_probabilities(spawn_weights)
