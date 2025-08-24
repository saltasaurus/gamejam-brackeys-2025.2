extends Enemy

func take_action() -> EntityAction:
    var action = EntityAction.new()
    action.type = EntityAction.Type.MOVE
    action.move_dir = Vector2.RIGHT
    return action
