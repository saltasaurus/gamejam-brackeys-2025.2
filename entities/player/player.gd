extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

@export var stats: CharacterStats

func _ready() -> void:
	# Uses an implicit, duck-typed interface for any compatible resources
	print("Health: ", stats.health.adjustedValue) 
	print("Strength: ", stats.strength.adjustedValue)
	print("Speed: ", stats.speed.adjustedValue)
		
