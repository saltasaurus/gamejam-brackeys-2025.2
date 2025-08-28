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

func update_stat(stats_mod: StatModifier, player_state_manager: TempStatManager) -> void:
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
