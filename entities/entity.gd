class_name Entity
extends Node2D

@export var stats: CharacterStats

signal health_updated(health: int)

# This is the current entity health.
# stats.health is the entity's BASE HEALTH.
var health: int

func _ready() -> void:
	stats._init()
	# Uses an implicit, duck-typed interface for any compatible resources
	print("Health: ", stats.health.adjustedValue) 
	print("Strength: ", stats.strength.adjustedValue)
	print("Speed: ", stats.speed.adjustedValue)
	print("Defense: ", stats.defense.adjustedValue)

	health = stats.health.baseValue

	health_updated.emit.call_deferred(health)
	
	add_to_group("entity")

func play_melee_attack_anim(dir: Vector2) -> void:
	var original_pos = position
	var target_pos = Vector2(position + (dir * 4))
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 0.05)
	await tween.finished

	tween = get_tree().create_tween()
	tween.tween_property(self, "position", original_pos, 0.05)
	await tween.finished

func take_damage(damage: int) -> void:
	if damage <= 0:
		damage = 0

	health -= damage
	if health < 0:
		health = 0
	
	health_updated.emit(health)

	if health == 0:
		# Ded
		EventManager.entity_died.emit(self)
	
func is_alive() -> bool:
	return health > 0
