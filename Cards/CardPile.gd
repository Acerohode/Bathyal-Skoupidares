extends Resource
class_name  CardPile

@export var cards : Array[Card]


func fetch_card() -> Card:
	var card_to_fetch = cards.pick_random()
	#cards.pop_at(randi_range(0,cards.size()))
	return card_to_fetch
