class_name Entity
extends Node2D

@export var stats: CharacterStats

@onready var on_screen: VisibleOnScreenNotifier2D

signal health_updated(health: int)

# This is the current entity health.
# stats.health is the entity's BASE HEALTH.
var health: int

var hurt_sound: AudioStream = preload("res://assets/sounds/player_hurt.wav")

func _ready() -> void:
	stats = stats.duplicate(true)
	stats._init()

	health = stats.health.adjustedValue
	print("HEALTH: ", health)

	health_updated.emit.call_deferred(health)

	on_screen = VisibleOnScreenNotifier2D.new()
	on_screen.rect = Rect2(0, 0, 10, 10)
	add_child(on_screen)
	
	add_to_group("entity")
	
func refresh_cached_stats() -> void:
	# QUICK FIX -> Must be called 
	health = stats.health.adjustedValue

	health_updated.emit.call_deferred(health)

func play_melee_attack_anim(dir: Vector2) -> void:
	var original_pos = position
	var target_pos = Vector2(position + (dir * 4))
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 0.05)
	await tween.finished

	tween = get_tree().create_tween()
	tween.tween_property(self, "position", original_pos, 0.05)
	await tween.finished
	
func update_stat(_statmod: StatModifier) -> void:
	stats.update_stat(_statmod, null)
	if _statmod.target == CharacterStats.Type.HEALTH:
		if health > stats.health.adjustedValue:
			health = stats.health.adjustedValue
			health_updated.emit(health)

func take_damage(damage: int) -> void:
	if damage <= 0:
		damage = 0

	health -= damage
	if health < 0:
		health = 0

	SoundManager.play(hurt_sound, position)
	
	health_updated.emit(health)
	if health == 0:
		# Ded
		EventManager.entity_died.emit(self)
	
func heal(amount: int) -> void:
	health += amount
	if health >= stats.health.adjustedValue:
		health = stats.health.adjustedValue

	health_updated.emit(health)

func is_alive() -> bool:
	return health > 0

func _update_stat(mod: StatModifier):
	stats.update_stat(mod, null)
	
