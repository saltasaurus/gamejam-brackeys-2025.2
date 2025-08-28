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
