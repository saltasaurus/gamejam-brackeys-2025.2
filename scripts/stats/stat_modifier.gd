class_name StatModifier
extends Resource

#region Variables
enum Type {
	ADD, 
	SUB,
	MULT,
	DIVIDE,
	PERCENT_ADD,
	PERCENT_SUB,
	PERCENT_MULT,
	PERCENT_DIVIDE
}

var target: CharacterStats.Type
var value : int = 0
var type : Type
var duration : float = 0 : set = set_duration
#endregion

#region Signals
signal modifier_over(_modifier : StatModifier)
#endregion

#region SET/GET
func set_duration(_newDuration : float) -> void:
	if _newDuration < 0:
		duration = _newDuration
		modifier_over.emit(self)
	else:
		duration = _newDuration
#endregion

func initialize(_value : int, _modifierType : Type, _target: CharacterStats.Type, _duration : float = 0) -> void:
	value = _value
	type = _modifierType
	target = _target
	duration = _duration
