class_name UI
extends Control

var world: World

@onready var floor_label: Label = $Floor
@onready var health_label: Label = $Health
@onready var strength_label: Label = $Strength
@onready var defense_label: Label = $Defense

func _process(_delta: float) -> void:
	floor_label.text = "Floor " + str(world.player_floor)

	var stats: CharacterStats = world.player.stats
	health_label.text = str(stats.health.adjustedValue) + "/" + str(stats.health.baseValue)
	strength_label.text = str(stats.strength.adjustedValue)
	defense_label.text = str(stats.defense.adjustedValue)
