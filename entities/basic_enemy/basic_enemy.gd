extends Enemy

func take_action(game: World) -> EntityAction:
	var path: PackedVector2Array = game.pathfind(position, game.player.position)
	var action = EntityAction.new()

	print(path)

	# TODO - Should technically check if player is adjacent
	var dir = game.get_adjacent_player_dir(self.position)
	if dir != Vector2.ZERO:
		action.type = EntityAction.Type.ATTACK_MELEE
		action.attack_dir = dir
	elif path.size() > 2:
		action.type = EntityAction.Type.MOVE
		action.move_dir = (path[1] - path[0]).normalized()
	else:
		action.type = EntityAction.Type.NONE
	
	return action
