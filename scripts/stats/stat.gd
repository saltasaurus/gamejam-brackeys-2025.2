extends Resource
class_name Stat

#region Variables
@export var baseValue : float = 0

var statModifiers : Array[StatModifier] = []
var adjustedValue : float = 0
#endregion

#region Signals
signal stat_adjusted(_stat : Stat)
#endregion

func initialize() -> void:
	adjustedValue = baseValue


func add_stat_modifier(_newStatModifier : StatModifier) -> void:
	statModifiers.append(_newStatModifier)
	_calculate_stat_modifiers()


func add_temp_stat_modifier(_newTempStatModifier : StatModifier, _tempStatManager : TempStatManager) -> void:
	statModifiers.append(_newTempStatModifier)
	_newTempStatModifier.modifier_over.connect(remove_stat_modifier)
	_tempStatManager.add_temp_stat(_newTempStatModifier)
	_calculate_stat_modifiers()


func remove_stat_modifier(_modifierToRemove : StatModifier) -> void:
	statModifiers.erase(_modifierToRemove)
	_calculate_stat_modifiers()


func remove_temp_stat_modifier(_modifierToRemove : StatModifier) -> void:
	statModifiers.erase(_modifierToRemove)
	_modifierToRemove.modifier_over.disconnect(remove_stat_modifier)
	_calculate_stat_modifiers()


func _calculate_stat_modifiers() -> void:
	adjustedValue = baseValue

	for statModifier in statModifiers:
		match statModifier.modifierType:
			StatModifier.StatModifierType.ADD:
				adjustedValue += statModifier.value
			StatModifier.StatModifierType.SUB:
				adjustedValue -= statModifier.value
			StatModifier.StatModifierType.MULT:
				adjustedValue *= statModifier.value
			StatModifier.StatModifierType.DIVIDE:
				adjustedValue /= statModifier.value
			StatModifier.StatModifierType.PERCENT_ADD:
				adjustedValue += (adjustedValue * statModifier.value) / 100
			StatModifier.StatModifierType.PERCENT_SUB:
				adjustedValue -= (adjustedValue * statModifier.value) / 100
			StatModifier.StatModifierType.PERCENT_MULT:
				adjustedValue *= (adjustedValue * statModifier.value) / 100
			StatModifier.StatModifierType.PERCENT_DIVIDE:
				adjustedValue /= (adjustedValue * statModifier.value) / 100
	 
	stat_adjusted.emit(self)	
