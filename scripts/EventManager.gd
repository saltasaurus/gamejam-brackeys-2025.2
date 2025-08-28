extends Node

signal level_passed(new_level: int)

signal card_selected(card: Array[StatModifier])

signal player_stats_updated(new_stats: CharacterStats)
signal player_health_updated(health: int)
