extends Node

@warning_ignore("unused_signal")
signal level_passed(new_level: int)

@warning_ignore("unused_signal")
signal card_selected(card: Array[StatModifier])

@warning_ignore("unused_signal")
signal player_stats_updated(new_stats: CharacterStats)
@warning_ignore("unused_signal")
signal player_health_updated(health: int)

@warning_ignore("unused_signal")
signal entity_died(entity: Entity)
