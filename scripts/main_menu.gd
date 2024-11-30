extends CanvasLayer

func _ready() -> void:
	show()
	get_tree().paused = true

func _on_credits_button_pressed() -> void:
	$Control.hide()
	$Soldiers.hide()
	$Credits.show()

func _on_return_pressed() -> void:
	$Control.show()
	$Soldiers.show()
	$Credits.hide()
	$HowToPlay.hide()

func _on_tutorial_button_pressed() -> void:
	$Control.hide()
	$Soldiers.hide()
	$HowToPlay.show()

func _on_start_button_pressed() -> void:
	get_tree().paused = false
	hide()
	$/root/Main/Reset.reset()
