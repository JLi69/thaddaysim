extends Node2D

func _on_move_pressed() -> void:
	get_parent().action = "move"
	hide()

func _on_landmine_pressed() -> void:
	get_parent().action = "landmine"
	hide()
