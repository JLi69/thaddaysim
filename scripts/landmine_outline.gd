extends Sprite2D

var tilex: int = 0
var tiley: int = 0

func _on_button_pressed() -> void:
	print("selected: ", tilex, ", ", tiley)
	
	$/root/Main.soldiers.remove_at(0)
	
	$/root/Main/Camera2D.zooming_in = false
	
	var soldier_node_path = $/root/Main.current_soldier
	var soldier = $/root/Main.get_node(soldier_node_path)
	soldier.get_node("Buttons").hide()
	soldier.action = ""
	
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	obstacles.set_cell(Vector2i(tilex, tiley), 0, Vector2i(3, 0))
	
	if len($/root/Main.soldiers) > 0:
		var world_pos = $/root/Main.get_node($/root/Main.soldiers[0]).get_world_pos()
		$/root/Main/Camera2D.start_zooming(world_pos.x, world_pos.y)
	
	var outlines = $/root/Main/Outlines
	for n in outlines.get_children():
		outlines.remove_child(n)
		n.queue_free()
