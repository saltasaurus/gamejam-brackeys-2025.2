class_name Player
extends Entity

@onready var sprite: Sprite2D = $Sprite2D
@onready var tempStatManager : TempStatManager = $StatManager

func _ready() -> void:
	super._ready()

	EventManager.connect("card_selected", _on_card_selected)
	
	# Tell world player is ready
	EventManager.emit_signal("player_stats_updated", stats)
	
func _on_card_selected(card_mods: Array[StatModifier]) -> void:
	for stat_mod in card_mods:
		stats.update_stat(stat_mod, tempStatManager)
	
	EventManager.emit_signal("player_stats_updated", stats)
	
