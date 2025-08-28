extends Control
class_name CardModifierUI

static var health_texture = preload("res://assets/ui/heart.png")
static var strength_texture = preload("res://assets/ui/damage.png")
static var defense_texture = preload("res://assets/ui/defense.png")

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Text

func set_modifier(m: StatModifier):
	var text = "???"
	match m.type:
		StatModifier.Type.ADD:
			text = "+" + str(m.value)
		StatModifier.Type.MULT:
			text = "x" + str(m.value)
		StatModifier.Type.SUB:
			text = "-" + str(m.value)

	var texture = null
	match m.target:
		CharacterStats.Type.HEALTH:
			texture = health_texture
		CharacterStats.Type.STRENGTH:
			texture = strength_texture
		CharacterStats.Type.DEFENSE:
			texture = defense_texture

	label.text = text
	icon.texture = texture
