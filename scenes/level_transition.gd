extends Control

static var card_scene = preload("res://scenes/Card.tscn")
static var y_pos = 40

func _ready() -> void:
	var duration = 3

	var s1 = StatModifier.new()
	s1.type = StatModifier.Type.ADD
	s1.duration = duration
	s1.target = CharacterStats.Type.STRENGTH
	s1.value = 3
	
	var m1 = CardModifier.new()
	m1.duration_floors = duration
	m1.modifiers.push_back(s1)
	m1.modifiers.push_back(s1)

	show_cards([
		m1,
		m1,
		m1
	])
	
	mouse_entered.connect(func(): print("mouse entered"))

func show_cards(modifiers: Array[CardModifier]) -> void:
	var spacing = 4

	var total_width = 0.0
	for m in modifiers:
		total_width += 54
	total_width += spacing * (modifiers.size() - 1)

	var x = (size.x - total_width) / 2
	for m in modifiers:
		var card = card_scene.instantiate() as Card
		card.modifier = m
		add_child(card)
		card.position = Vector2(x, y_pos)
		card.focused_pos = y_pos
		card.unfocused_pos = y_pos + 6
		x += 54 + spacing
		card.grab_focus()

	
