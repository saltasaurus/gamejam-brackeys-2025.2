extends Enemy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func take_action(game: World) -> EntityAction:
	var path: PackedVector2Array = game.pathfind(position, game.player.position)
	var action = EntityAction.new()

	var dir = game.get_adjacent_player_dir(self.position)
	print("DIRECTION TO PLAYER: ", dir)
	if dir != Vector2.ZERO:
		action.type = EntityAction.Type.ATTACK_MELEE
		action.attack_dir = dir
		sprite.face_direction(dir)
		print("ATTACKING IN ", action.attack_dir)
	elif path.size() > 2:
		action.type = EntityAction.Type.MOVE
		action.move_dir = (path[1] - path[0]).normalized()
		sprite.face_direction(action.move_dir)
		print("MOVING IN ", action.move_dir)
	else:
		action.type = EntityAction.Type.NONE
	
	return action
