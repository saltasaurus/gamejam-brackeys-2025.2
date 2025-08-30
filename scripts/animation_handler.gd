extends AnimatedSprite2D

var _facing_right: bool = true

func _get_direction(dir: Vector2) -> String:
	if dir.y < 0: # Up decreases Y
		return "face_up"
	
	# Set direction to right
	if dir.x > 0:
		_facing_right = true
		return "face_right"
	elif dir.x < 0:
		_facing_right = false
		return "face_left"
	# Do not override last direction when moving down
	elif _facing_right:
		return "face_right"
	else:
		return "face_left"

	
func face_direction(dir: Vector2) -> void:
	print("GIVEN DIRECTION: ", dir)
	var direction = _get_direction(dir)
	print(direction)
	play(_get_direction(dir))
	print()
