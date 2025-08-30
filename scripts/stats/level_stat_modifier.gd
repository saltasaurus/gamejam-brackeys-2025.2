class_name LevelStatModifier

enum Type {
	# Simple (for example +3, 2x)
	BASIC,
}

var type: Type
var duration_floors: int

var basic_target_stat: Type
var basic_modifier: StatModifier

# Apply modifier to character stats
func apply(stats: CharacterStats):
	match type:
		Type.BASIC:
			apply_basic(stats)

func apply_basic(stats: CharacterStats):
	stats.update_stat(basic_modifier, null)
