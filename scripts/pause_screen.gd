extends CanvasLayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and not $/root/Main/MainMenu.visible:
		$/root/Main/WinScreen.hide()
		get_tree().paused = not get_tree().paused
		visible = not visible

func _on_no_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_yes_pressed() -> void:
	hide()
	$/root/Main/MainMenu.show()
