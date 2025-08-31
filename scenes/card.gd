class_name Card
extends Control

static var card_scene = preload("res://scenes/CardModifier.tscn")

var modifier: CardModifier

@onready var vbox = $VBox
@onready var top = $Top

var focused_pos
var unfocused_pos

func _ready() -> void:
	for m in modifier.modifiers:
		var card: CardModifierUI = (card_scene.instantiate() as CardModifierUI)
		vbox.add_child(card)
		card.set_modifier(m)

	if modifier.enemy_count > 0:
		var mod: CardModifierUI = (card_scene.instantiate() as CardModifierUI)
		vbox.add_child(mod)
		mod.set_enemy_count(modifier.enemy_count)

	if modifier.heal_amount > 0:
		var mod: CardModifierUI = (card_scene.instantiate() as CardModifierUI)
		vbox.add_child(mod)
		mod.set_heal_amount(modifier.heal_amount)

func _process(_delta: float) -> void:
	if has_focus():
		top.position.y = focused_pos
	else:
		top.position.y = unfocused_pos
