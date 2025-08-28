class_name Card
extends NinePatchRect

static var card_scene = preload("res://scenes/CardModifier.tscn")

var modifier: CardModifier

@onready var vbox = $VBox
@onready var duration_label: Label = $Duration

var focused_pos
var unfocused_pos

func _ready() -> void:
	for m in modifier.modifiers:
		var card: CardModifierUI = (card_scene.instantiate() as CardModifierUI)
		vbox.add_child(card)
		card.set_modifier(m)

	duration_label.text = str(modifier.duration_floors) + " floors"

func _process(_delta: float) -> void:
	if has_focus():
		position.y = focused_pos
	else:
		position.y = unfocused_pos
