class_name Player
extends Entity

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tempStatManager : TempStatManager = $StatManager

var _facing_right: bool = true

func _ready() -> void:
	super._ready()

	EventManager.connect("card_selected", _on_card_selected)
	EventManager.connect("player_stat_modified", _on_player_stat_modified)
	
	# Tell world player is ready
	EventManager.emit_signal("player_stats_updated", stats)
	
## Updates player stats based on selected card and emits
## player_stats_updated signal
func _on_card_selected(card: CardModifier) -> void:
	
	for stat_mod in card.modifiers:
		stats.update_stat(stat_mod, tempStatManager)
	
	EventManager.emit_signal("player_stats_updated", stats)

func _on_player_stat_modified(_statmod: StatModifier):
	stats.update_stat(_statmod, null)
	EventManager.emit_signal("player_stats_updated", stats)
	print("UPDATED PLAYER STAT")
	print(stats.strength)
	
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
	sprite.play(_get_direction(dir))
	
func die() -> void:
	sprite.play("die")
