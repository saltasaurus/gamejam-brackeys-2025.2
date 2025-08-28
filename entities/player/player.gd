class_name Player
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var tempStatManager : TempStatManager = $StatManager

@export var stats: CharacterStats


func _ready() -> void:
	stats._init()
	# Uses an implicit, duck-typed interface for any compatible resources
	print("Health: ", stats.health.adjustedValue) 
	print("Strength: ", stats.strength.adjustedValue)
	print("Speed: ", stats.speed.adjustedValue)
	print("Defense: ", stats.defense.adjustedValue)
	
	EventManager.connect("card_selected", _on_card_selected)
	
	# Tell world player is ready
	EventManager.emit_signal("player_stats_updated", stats)
	
func _on_card_selected(card_mods: Array[StatModifier]) -> void:
	for stat_mod in card_mods:
		stats.update_stat(stat_mod, tempStatManager)
	
	EventManager.emit_signal("player_stats_updated", stats)
		
