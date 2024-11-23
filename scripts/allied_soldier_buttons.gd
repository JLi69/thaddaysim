extends Node2D

func _on_move_pressed() -> void:
	get_parent().action = "move"
	hide()
