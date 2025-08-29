class_name WeaponItem
extends Item

@export var strength_amount: int

var stat_modifier: StatModifier

func _init() -> void:
	stat_modifier = StatModifier.new()
	stat_modifier.type = StatModifier.Type.ADD
	stat_modifier.duration = 0
	stat_modifier.target = CharacterStats.Type.STRENGTH
	stat_modifier.value = strength_amount
