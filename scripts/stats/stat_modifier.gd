extends Object
class_name StatModifier

#region Variables
enum StatModifierType {
	ADD, 
	SUB,
	MULT,
	DIVIDE,
	PERCENT_ADD,
	PERCENT_SUB,
	PERCENT_MULT,
	PERCENT_DIVIDE
}

var value : float = 0
var modifierType : StatModifierType
var duration : float = 0 : set = set_duration
#endregion

#region Signals
signal modifier_over(_modifier : StatModifier)
#endregion

#region SET/GET
func set_duration(_newDuration : float) -> void:
	if _newDuration <= 0:
		duration = 0
		modifier_over.emit(self)
	else:
		duration = _newDuration
#endregion

func initialize(_value : float, _modifierType : StatModifierType, _duration : float = 0) -> void:
	value = _value
	modifierType = _modifierType
	duration = _duration
