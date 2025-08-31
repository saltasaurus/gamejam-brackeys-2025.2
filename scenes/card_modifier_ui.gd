extends Control
class_name CardModifierUI

static var health_texture = preload("res://assets/ui/heart.png")
static var strength_texture = preload("res://assets/ui/damage.png")
static var defense_texture = preload("res://assets/ui/defense.png")
static var enemy_texture = preload("res://assets/ui/enemy.png")
static var heal_texture = preload("res://assets/ui/heal.png")

const GOOD_COLOR := Color("a8ca58")
const BAD_COLOR := Color("cf573c")

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Text

func set_modifier(m: StatModifier):
	var text = "???"
	var color = Color.WHITE
	match m.type:
		StatModifier.Type.ADD:
			text = "+" + str(m.value)
			color = GOOD_COLOR
		StatModifier.Type.MULT:
			text = "x" + str(m.value)
			color = GOOD_COLOR
		StatModifier.Type.SUB:
			text = "-" + str(m.value)
			color = BAD_COLOR

	var texture = null
	match m.target:
		CharacterStats.Type.HEALTH:
			texture = health_texture
		CharacterStats.Type.STRENGTH:
			texture = strength_texture
		CharacterStats.Type.DEFENSE:
			texture = defense_texture

	label.text = text
	label.add_theme_color_override("font_color", color)
	icon.texture = texture

func set_enemy_count(count: int):
	label.text = "+" + str(count)
	icon.texture = enemy_texture
	label.add_theme_color_override("font_color", BAD_COLOR)
	
func set_heal_amount(amount: int):
	label.text = "+" + str(amount)
	icon.texture = heal_texture
	label.add_theme_color_override("font_color", GOOD_COLOR)
