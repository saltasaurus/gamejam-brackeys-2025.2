extends Resource
class_name CharacterStats

enum Type {
	HEALTH,
	STRENGTH,
	DEFENSE
}

#region Variables
@export var health: Stat
@export var strength: Stat
@export var defense: Stat
#endregion

func _init() -> void:
	if health != null:
		health._init()

	if strength != null:
		strength._init()

	if defense != null:
		defense._init()

func update_stats(stat_mods: Array[StatModifier]) -> void:
	for stat_mod in stat_mods:
		update_stat(stat_mod, null)

func update_stat(stats_mod: StatModifier, player_state_manager: TempStatManager) -> void:
	var stat_type: Stat
	match stats_mod.target:
		Type.HEALTH:
			if health != null:
				stat_type = health
		Type.STRENGTH:
			if strength != null:
				stat_type = strength
		Type.DEFENSE:
			if defense != null:
				stat_type = defense
				
	if player_state_manager == null:
		stat_type.add_stat_modifier(stats_mod)
	else:
		stat_type.add_temp_stat_modifier(stats_mod, player_state_manager)
