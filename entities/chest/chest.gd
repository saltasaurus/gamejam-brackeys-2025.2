extends Interactable

@export var chest_open: Texture2D

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	pass

func interact(source: Entity) -> void:
	sprite.texture = chest_open
