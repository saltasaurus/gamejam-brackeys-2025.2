class_name Player
extends Entity

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tempStatManager : TempStatManager = $StatManager

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
		_update_stat(stat_mod)
	EventManager.emit_signal("player_stats_updated", stats)

func _on_player_stat_modified(stat_mod: StatModifier):
	_update_stat(stat_mod)
	EventManager.emit_signal("player_stats_updated", stats)
	
func face_direction(dir: Vector2) -> void:
	sprite.face_direction(dir)
	
func die() -> void:
	sprite.play("die")
