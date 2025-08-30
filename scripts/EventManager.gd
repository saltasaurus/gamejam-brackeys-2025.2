extends Node

signal level_passed(new_level: int)

signal card_selected(card: CardModifier)

signal player_stats_updated(new_stats: CharacterStats)
signal player_stat_modified(_statmod: StatModifier)
signal player_health_updated(health: int)

signal entity_died(entity: Entity)

signal chest_opened(item: Item)
