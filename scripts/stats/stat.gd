extends Resource
class_name Stat

#region Variables
@export var baseValue : int

var statModifiers : Array[StatModifier] = []
var adjustedValue : int = baseValue
#endregion

#region Signals
signal stat_adjusted(_stat : Stat)
#endregion

func _init() -> void:
	adjustedValue = baseValue
	statModifiers.clear()

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
		match statModifier.type:
			StatModifier.Type.ADD:
				adjustedValue += statModifier.value
			StatModifier.Type.SUB:
				adjustedValue -= statModifier.value
			StatModifier.Type.MULT:
				adjustedValue *= statModifier.value
			StatModifier.Type.DIVIDE:
				adjustedValue /= statModifier.value
			StatModifier.Type.PERCENT_ADD:
				adjustedValue += (adjustedValue * statModifier.value) / 100
			StatModifier.Type.PERCENT_SUB:
				adjustedValue -= (adjustedValue * statModifier.value) / 100
			StatModifier.Type.PERCENT_MULT:
				adjustedValue *= (adjustedValue * statModifier.value) / 100
			StatModifier.Type.PERCENT_DIVIDE:
				adjustedValue /= (adjustedValue * statModifier.value) / 100
	 
	stat_adjusted.emit(self)	
