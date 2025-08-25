extends Enemy

func take_action(game: Game) -> EntityAction:
	var path: PackedVector2Array = game.pathfind(position, game.player.position)
	var action = EntityAction.new()

	if path.size() == 2:
		# Adjacent to player
		action.type = EntityAction.Type.ATTACK
		action.attack_dir = (path[1] - path[0]).normalized()
		print("attack")
	elif path.size() > 2:
		action.type = EntityAction.Type.MOVE
		action.move_dir = (path[1] - path[0]).normalized()
	else:
		action.type = EntityAction.Type.NONE
	
	return action
