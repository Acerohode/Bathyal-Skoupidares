extends Control

var mousing : bool = false
var lmousing : bool = false
var rmousing : bool = false
var opened : bool = false

var curr_y : float

@onready var grace_timer: Timer = $Grace_Timer

@onready var iso_page: TextureRect = $IsoPage

var left_magnitude = 3
var right_magnitude = 0

var name_1 : String =  "[center][i] Bathynomus doederleinii[/i][/center]"
var description_1 = "[b]Take [/b]"+str(left_magnitude)+"chunks [b]off the whale carcass[/b]"
var name_2 : String = "[center][i] Bathynomus sacrisanctii[/i][/center]"
var description_2 : String = "Sacrifice isopod to lower cost of cards in hand by 1"
const image_1 = preload("res://Assets/IsoIMG0001.png")
const image_2 = preload("res://Assets/IsoIMG0002.png")
@onready var image: TextureRect = $IsoPage/MarginContainer/MarginContainer/VBoxContainer/Image
@onready var name_label: RichTextLabel = $IsoPage/MarginContainer/MarginContainer/VBoxContainer/Name
@onready var description: RichTextLabel = $IsoPage/MarginContainer/MarginContainer/VBoxContainer/Description

@onready var left: Control = $IsoPage/MarginContainer/Buttons/Left
@onready var right: Control = $IsoPage/MarginContainer/Buttons/Right

var buff_timer : int

func _ready() -> void:
	curr_y = self.position.y
	connect("mouse_entered",mouseon)
	connect("mouse_exited",mouseoff)
	left.connect("mouse_entered",lmouseon)
	left.connect("mouse_exited",lmouseoff)
	right.connect("mouse_entered",rmouseon)
	right.connect("mouse_exited",rmouseoff)
	SignalBus.connect("buff",buff)
	SignalBus.connect("turn_done",turn_check)

func turn_check():
	if buff_timer > 0:
		buff_timer -=1
	if buff_timer == 0:
		description_1 = "[b]Take [/b]"+str(left_magnitude)+"chunks [b]off the whale carcass[/b]"

func buff(magnitude:int):
	buff_timer += magnitude*2
	description_1 = "[b]Steal [/b]"+str(left_magnitude)+"chunks [b]from opponent[/b]"

func mouseon():
	mousing = true
	var tween = create_tween()
	tween.tween_property(self,"position:y",curr_y-100,0.2)

func mouseoff():
	if not opened:
		mousing = false
		var tween = create_tween()
		tween.tween_property(self,"position:y",curr_y,0.2)

func lmouseon():
	lmousing = true
	name_label.text = name_1
	image.texture = image_1
	description.text = description_1
	

func lmouseoff():
	grace_timer.start(0.1)
	lmousing = false


func rmouseon():
	rmousing = true
	name_label.text = name_2
	image.texture = image_2
	description.text = description_2

func rmouseoff():
	grace_timer.start(0.1)
	rmousing = false



func _input(event: InputEvent) -> void:
	if event.is_action_released("click") && mousing:
		grace_timer.start(0.1)
		open_up()
	if opened && not lmousing && not rmousing && grace_timer.is_stopped():
		close()
	if event.is_action_released("click") && lmousing:
		steal_chunks()
	if event.is_action_released("click") && rmousing:
		discard()

func open_up():
	opened = true
	self_modulate.a = 0
	iso_page.show_behind_parent = false
	mouse_filter = 2
	left.mouse_filter = 0
	right.mouse_filter = 0

func close():
	opened = false
	mousing = false
	iso_page.show_behind_parent = true
	self_modulate.a = 1
	mouse_filter = 0
	left.mouse_filter = 2
	right.mouse_filter = 2
	var tween = create_tween()
	tween.tween_property(self,"position:y",curr_y,0.2)

func steal_chunks() ->void:
	SignalBus.steal_chunks.emit(left_magnitude)
	SignalBus.turn_done.emit()

func discard() -> void:
	SignalBus.discard.emit()
	SignalBus.turn_done.emit()
