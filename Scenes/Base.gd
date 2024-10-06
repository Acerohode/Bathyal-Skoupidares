extends Node2D

var current_meat : int
@onready var label: Label = $Meat/Label
@export var player_base : bool
@onready var meat: Sprite2D = $Meat
@onready var shield: Sprite2D = $Shield
@onready var thinking: Sprite2D = $"../Base2/Sprite2D"

var active_base: bool = false

var buff_timer : int = 0
var shield_timer : int = 0


func _ready() -> void:
	SignalBus.connect("turn_done",turn)
	SignalBus.connect("give",add_meat)
	SignalBus.connect("shield",shield_up)
	SignalBus.connect("global_loss",lose)
	if player_base:
		active_base = true
	if not player_base:
		meat.scale.x = -meat.scale.x
	current_meat = 0
	update_meat()


func lose(amount:int):
	if player_base:
		current_meat -= amount
		update_meat()



func turn():
	update_meat()
	if player_base && active_base:
		SignalBus.meat_check.emit(current_meat)
	active_base = !active_base
	if not player_base:
		if active_base:
			thinking.show()
		else:
			thinking.hide()

func update_meat():
	label.text = str(current_meat)

func steal_from_opponent(magnitude:int):
	if not active_base:
		if shield_timer > 0:
			shield_timer -= 1
			if shield_timer < 0:
				shield.hide()
			return
		var delta = current_meat - magnitude
		if delta < 0:
			SignalBus.give.emit(current_meat)
			current_meat = 0
			update_meat()
			return
		SignalBus.give.emit(magnitude)
		current_meat -= magnitude
		update_meat()

func shield_up(magnitude:int):
	if active_base:
		shield_timer += magnitude
		shield.show()


func add_meat(how_much: int):
	if active_base:
		current_meat += how_much
		update_meat()
