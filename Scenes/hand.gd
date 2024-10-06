extends Control


@onready var hand_container: HBoxContainer = $HandContainer

var hand : Array[Control]


func needs_filling() -> bool:
	if hand_container.get_child_count() < 3:
		return true
	else: return false
