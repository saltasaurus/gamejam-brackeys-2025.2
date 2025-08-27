class_name UI
extends Control

var world: World

@onready var floor_label: Label = $Floor
@onready var health_label: Label = $Health

func _process(_delta: float) -> void:
	floor_label.text = "Floor " + str(world.player_floor)
