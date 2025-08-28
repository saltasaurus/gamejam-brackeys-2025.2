class_name RogueStatusIndicator
extends Label

func _ready() -> void:
	var target_pos = position + (5 * Vector2.UP)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 0.1).set_trans(Tween.TRANS_ELASTIC)

	await get_tree().create_timer(0.5).timeout
	queue_free()
