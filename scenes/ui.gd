class_name UI
extends Control

#var world: World

@onready var floor_label: Label = $Floor
@onready var health_label: Label = $Health
@onready var strength_label: Label = $Strength
@onready var defense_label: Label = $Defense

var player_health: int
var player_base_health: int

func _ready() -> void:
	EventManager.connect("level_passed", _on_level_passed)
	EventManager.connect("player_stats_updated", _on_player_stats_updated)
	EventManager.connect("player_health_updated", _on_player_health_updated)

func _on_level_passed(new_level: int) -> void:
	floor_label.text = "Floor " + str(new_level)
	
func _on_player_stats_updated(new_stats: CharacterStats) -> void:
	player_base_health = new_stats.health.baseValue
	health_label.text = str(player_health) + "/" + str(player_base_health)
	strength_label.text = str(new_stats.strength.adjustedValue)
	defense_label.text = str(new_stats.defense.adjustedValue)

func _on_player_health_updated(health: int) -> void:
	player_health = health
	health_label.text = str(player_health) + "/" + str(player_base_health)
