extends Node

var turn_num : int = 0
var player_turn : bool = true
const CARD = preload("res://Scenes/card.tscn")

@export var deck : CardPile
@onready var hand: Control = $"../Hand"
@onready var hand_container: HBoxContainer = $"../Hand/HandContainer"
@onready var turn_grace: Timer = $Timer

@onready var turn_image: TextureRect = $Turn
@onready var base: Node2D = $"../Base"
@onready var base_2: Node2D = $"../Base2"
@onready var turn_grace2: Timer = $Timer2
@onready var meat_total: Label = $MeatTotal
@onready var meat_win: Label = $MeatWin
@onready var win: ColorRect = $Win
@onready var label: Label = $Win/Label


var total_meat : int = 32
var meat_to_win : int 
@onready var skeleton: Node2D = $"../Skeleton"


func _ready() -> void:
	SignalBus.connect("turn_done",turn_over)
	add_card()
	add_card()
	add_card()
	SignalBus.connect("global_loss",lose_meat)
	SignalBus.connect("global_gain",lose_meat)
	calculate_meat()

func lose_meat(amount:int):
	total_meat -= amount
	calculate_meat()

func gain_meat(amount:int):
	total_meat += amount
	calculate_meat()



func calculate_meat():
	meat_to_win = roundi(total_meat*0.75)
	meat_total.text = "In game total: "+ str(total_meat)
	meat_win.text = "To win: "+ str(meat_to_win)

func fetch_cards() -> void:
	for n in 2:
		var selected = deck.cards[randi_range(0,deck.cards.size())]

func turn_over():
	if hand_container.get_child_count() < 3:
			add_card()
	check_win()
	turn_num += 1
	player_turn = !player_turn
	var tween1 = create_tween()
	tween1.tween_property(turn_image,"position:y",-262,0.4).set_ease(Tween.EASE_OUT)
	await tween1.finished
	if not player_turn:
		var tween3 = create_tween()
		tween3.tween_property(hand,"position:y",1000,0.2).set_ease(Tween.EASE_OUT)
		AI_turn()
	turn_grace2.start(0.5)
	await turn_grace2.timeout
	var tween2 = create_tween()
	tween2.tween_property(turn_image,"position:y",-800,0.4).set_ease(Tween.EASE_IN)
	await tween2.finished
	if player_turn:
		var tween4 = create_tween()
		tween4.tween_property(hand,"position:y",298,0.2).set_ease(Tween.EASE_OUT)
		await tween2.finished

func is_player_turn() -> bool:
	return player_turn

func add_card():
	var card_instance = CARD.instantiate()
	card_instance.card_res = deck.fetch_card()
	hand_container.add_child(card_instance)


func AI_turn():
	if base_2.current_meat < 10 && skeleton.health > 0:
		SignalBus.steal_chunks.emit(3)
		turn_grace.start(1)
		await turn_grace.is_stopped()
		SignalBus.turn_done.emit()
		return
	if skeleton.health > 0:
		if randi_range(0,2) == 0:
			SignalBus.steal_chunks.emit(3)
			turn_grace.start(1)
			await turn_grace.is_stopped()
			SignalBus.turn_done.emit()
			return
	match randi_range(0,1):
		0:SignalBus.scavenge.emit(5)
		1:SignalBus.scavenge.emit(5)
	turn_grace.start(3)
	await turn_grace.timeout
	SignalBus.turn_done.emit()

func check_win():
	if base.current_meat >= meat_to_win:
		win.show()
	if base_2.current_meat >= meat_to_win:
		win.show()
		label.text = "You lost"
