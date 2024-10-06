extends Control

var mousing : bool = false
var card_res : Card


@onready var texture_rect: TextureRect = $TextureRect
@onready var number: RichTextLabel = $TextureRect/MarginContainer/Number
@onready var cardname: RichTextLabel = $TextureRect/MarginContainer/MarginContainer/VBoxContainer/Name
@onready var image: TextureRect = $TextureRect/MarginContainer/MarginContainer/VBoxContainer/Image
@onready var tooltip: RichTextLabel = $TextureRect/MarginContainer/MarginContainer/VBoxContainer/Tooltip

var magnitude : int 
var cost_modifier : int = 0 

var current_player_meat:int = 0

func _ready() -> void:
	connect("mouse_entered",mouseon)
	connect("mouse_exited",mouseoff)
	SignalBus.connect("discard", modify_cost)
	render_card()
	SignalBus.connect("meat_check",update_current_meat)

func modify_cost() -> void:
	cost_modifier += 1
	number.text = "Cost:"+str(clampi(card_res.number-cost_modifier,1,100))

func update_current_meat(amount:int):
	current_player_meat = amount
	print(current_player_meat)

func render_card():
	number.text = "Cost:"+str(card_res.number)
	cardname.text = card_res.name
	image.texture = card_res.image
	tooltip.text = card_res.tooltip
	magnitude = card_res.magnitude


func mouseon():
	mousing = true
	print(mousing)
	var tween = create_tween()
	tween.tween_property(self,"position:y",-100,0.2)

func mouseoff():
	mousing = false
	var tween = create_tween()
	tween.tween_property(self,"position:y",0,0.2)

func _input(event: InputEvent) -> void:
	if event.is_action_released("click") && mousing:
		if current_player_meat >= clampi(card_res.number-cost_modifier,1,100):
			activate_card()


func activate_card() -> void:
	match card_res.type:
		0:SignalBus.steal_from_opponent.emit(magnitude)
		1:SignalBus.buff.emit(magnitude)
		2:SignalBus.shield.emit(magnitude)
		3:SignalBus.scavenge.emit(magnitude)
	SignalBus.global_loss.emit(clampi(card_res.number-cost_modifier,1,100))
	SignalBus.turn_done.emit()
	queue_free()
