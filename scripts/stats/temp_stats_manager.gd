extends Node
class_name TempStatManager

#region Variables
var tempStats : Array[StatModifier]
#endregion

func add_temp_stat(_newTempStatModifier : StatModifier) -> void:
	if _newTempStatModifier.duration > 0:
		tempStats.append(_newTempStatModifier)
		return
	printerr("ERROR: Tried to add a temp stat modifier to StatManager that was not a temp stat modifier")
	
func _process(delta: float) -> void:
	# TODO: This uses _process and delta time to determine temp stat lifetimes.
	# However, we use a "turn-based" movement system, and as such should reflect that
	# By only removing time during a movement (maybe a signal?)
	
	var statsToRemove : Array[StatModifier] = []
	
	for tempStat in tempStats:
		tempStat.duration -= get_process_delta_time()
		
		if tempStat.duration <= 0:
			statsToRemove.append(tempStat)
			
	for statToRemove in statsToRemove:
		tempStats.erase(statToRemove)
		
	statsToRemove.clear()
