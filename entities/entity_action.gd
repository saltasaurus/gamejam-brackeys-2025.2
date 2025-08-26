class_name EntityAction

enum Type {
	NONE,
	MOVE,
	ATTACK,
}

var type: Type

# Type.MOVE
var move_dir: Vector2

# Type.ATTACK
var attack_dir: Vector2
