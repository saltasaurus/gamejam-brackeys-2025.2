extends Control
class_name LevelTransition

static var card_scene = preload("res://scenes/Card.tscn")
static var y_pos = 0

var cards: Array[Card] = []

signal selected(modifier: CardModifier)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused is Card:
			selected.emit((focused as Card).modifier)

func clear_cards() -> void:
	for c in get_children():
		c.queue_free()
	cards.clear()

func show_cards(modifiers: Array[CardModifier]) -> void:
	clear_cards()

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
		cards.push_back(card)

	cards[0].grab_focus()
