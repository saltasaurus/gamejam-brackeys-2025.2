extends Resource
class_name CharacterStats

enum Type {
	HEALTH,
	STRENGTH,
	DEFENSE,
	SPEED
}

#region Variables
@export var health: Stat
@export var strength: Stat
@export var defense: Stat
@export var speed: Stat
#endregion

func _init() -> void:
	if health != null:
		health._init()

	if strength != null:
		strength._init()

	if defense != null:
		defense._init()

	if speed != null:
		speed._init()

func add_temp_stat(stats_mod: StatModifier, player_state_manager: TempStatManager) -> void:
	match stats_mod.target:
		Type.HEALTH:
			if health != null:
				health.add_temp_stat_modifier(stats_mod, player_state_manager)
				print("Health modified")
		Type.STRENGTH:
			if strength != null:
				strength.add_temp_stat_modifier(stats_mod, player_state_manager)
				print("Strength modified")
		Type.DEFENSE:
			if defense != null:
				defense.add_temp_stat_modifier(stats_mod, player_state_manager)
				print("Defense modified")
		Type.SPEED:
			if speed != null:
				speed.add_temp_stat_modifier(stats_mod, player_state_manager)
				print("Speed modified")

func update_stat(stats_mod: StatModifier, player_state_manager: TempStatManager) -> void:
	var stat_type: Stat
	match stats_mod.target:
		Type.HEALTH:
			if health != null:
				stat_type = health
				print("Health modified")
		Type.STRENGTH:
			if strength != null:
				stat_type = strength
				print("Strength modified")
		Type.DEFENSE:
			if defense != null:
				stat_type = defense
				print("Defense modified")
		Type.SPEED:
			if speed != null:
				stat_type = speed
				print("Speed modified")
				
	print("Adding ", stats_mod.value, " to ", stats_mod.target)
	if player_state_manager == null:
		stat_type.add_stat_modifier(stats_mod)
		print("Added permanent stat: ", stat_type.baseValue, " ", stat_type.adjustedValue)
	else:
		stat_type.add_temp_stat_modifier(stats_mod, player_state_manager)
		print("Added temp stat: ", stat_type)
