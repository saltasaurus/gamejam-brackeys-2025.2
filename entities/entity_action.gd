class_name EntityAction

enum Type {
	NONE,
	MOVE,
	ATTACK_MELEE,
}

var type: Type

# Type.MOVE
var move_dir: Vector2

# Type.ATTACK_MELEE
var attack_dir: Vector2
