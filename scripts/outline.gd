extends Sprite2D

var tilex: int = 0
var tiley: int = 0

func _process(_delta: float) -> void:
	if Input.is_action_pressed("camera_move"):
		$Button.hide()
	else:
		$Button.show()

func _on_button_pressed() -> void:
	print("selected: ", tilex, ", ", tiley)
	
	$/root/Main.soldiers.remove_at(0)
	
	$/root/Main/Camera2D.zooming_in = false
	
	var soldier_node_path = $/root/Main.current_soldier
	var soldier = $/root/Main.get_node(soldier_node_path)
	soldier.targetx = tilex
	soldier.targety = tiley
	soldier.startx = soldier.get_tile_pos().x
	soldier.starty = soldier.get_tile_pos().y
	soldier.animation = "walking"
	
	var outlines = $/root/Main/Outlines
	for n in outlines.get_children():
		outlines.remove_child(n)
		n.queue_free()
