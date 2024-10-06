extends Node2D

var base_health : int = 32
var health :int
@onready var label: Label = $Meat/Label

var chunker_count : int = 0


func _ready() -> void:
	health = base_health
	SignalBus.connect("steal_chunks",take)
	SignalBus.connect("scavenge",scavenge)
	update_health()
	SignalBus.connect("turn_done",update_health)


func update_health() -> void:
	label.text = str(health)

func take(magnitude:int) -> void:
	var delta = health - magnitude
	if delta < 0:
		SignalBus.give.emit(health)
		health = 0
		update_health()
		return
	health -= magnitude
	SignalBus.give.emit(magnitude)
	update_health()

func scavenge(magnitude:int):
	health += magnitude
	SignalBus.global_gain.emit(magnitude)
	update_health()
