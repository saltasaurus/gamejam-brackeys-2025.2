extends Node
class_name TempStatManager

#region Variables
var tempStats : Array[StatModifier]
#endregion

func _ready() -> void:
	EventManager.connect("level_passed", _on_next_level)

## Adds a stat modifier for the given duration
func add_temp_stat(_newTempStatModifier : StatModifier) -> void:
	if _newTempStatModifier.duration > 0:
		tempStats.append(_newTempStatModifier)
		return
	printerr("ERROR: Tried to add a temp stat modifier to StatManager that was not a temp stat modifier")
	
func _on_next_level(_level: int) -> void:
	print("Next level")
	var statsToRemove : Array[StatModifier] = []
	
	for tempStat in tempStats:
		tempStat.duration -= 1
		# Level update happens first, so remove after the current level
		if tempStat.duration < 0:
			statsToRemove.append(tempStat)
		else:
			print("+",tempStat.value, " for ", tempStat.duration, " more floors")
			
	for statToRemove in statsToRemove:
		tempStats.erase(statToRemove)
		print("-", statToRemove.value, " next floor")
		
	statsToRemove.clear()
