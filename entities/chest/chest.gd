class_name Chest
extends Interactable

@export var chest_open: Texture2D
@export var item: Item

@onready var sprite: Sprite2D = $Sprite
@onready var item_sprite: Sprite2D = $ItemSprite

var is_open: bool = false

signal opened(item: Item)

func _ready() -> void:
	item_sprite.visible = false

func interact(_source: Entity) -> void:
	# Prevent opening chest multiple times
	if is_open:
		return
	sprite.texture = chest_open
	
	item_sprite.texture = item.texture
	item_sprite.visible = true

	var fade_color = Color.WHITE
	fade_color.a = 0
	var target_pos = item_sprite.position + 8 * Vector2.UP
	var tween = get_tree().create_tween()
	tween.tween_property(item_sprite, "position", target_pos, 0.1).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(item_sprite, "modulate", fade_color, 0.5).set_trans(Tween.TRANS_SINE)

	opened.emit(item)
	is_open = true
	
