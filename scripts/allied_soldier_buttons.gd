extends Node2D

func _on_move_pressed() -> void:
	get_parent().action = "move"
	hide()

func _on_heal_pressed() -> void:
	get_parent().action = "heal"
	hide()

func _on_shoot_pressed() -> void:
	get_parent().action = "shoot"
	hide()
