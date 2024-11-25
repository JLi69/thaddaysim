extends CanvasLayer

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	# Determine if win condition has been met
	var allies_count = $/root/Main/AlliedSoldiers.get_child_count()
	var axis_count = $/root/Main/AxisSoldiers.get_child_count()
	if allies_count == 0 and axis_count > 0:
		show()
		$Control/VBoxContainer/WinText.text = "Axis Win!"
		$Control/VBoxContainer/Subtext.text = "Welp, D-Day failed :("
		$/root/Main.game_over = true
	elif allies_count > 0 and axis_count == 0:
		show()
		$Control/VBoxContainer/WinText.text = "Allies Win!"
		$Control/VBoxContainer/Subtext.text = "All Axis soldiers are dead."
		$/root/Main.game_over = true
	elif $/root/Main/Flag.captured:
		show()
		$Control/VBoxContainer/WinText.text = "Allies Win!"
		$Control/VBoxContainer/Subtext.text = "The Allies have captured the flag,\nFrance has been liberated!"
		$/root/Main.game_over = true
