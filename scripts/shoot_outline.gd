extends Sprite2D

var tilex: int = 0
var tiley: int = 0

const knockback_speed: float = 32.0

func _process(_delta: float) -> void:
	if Input.is_action_pressed("camera_move"):
		$Button.hide()
	else:
		$Button.show()

func _on_button_pressed() -> void:
	print("selected: ", tilex, ", ", tiley)
	
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	if obstacles.get_cell_tile_data(Vector2i(tilex, tiley)) != null and obstacles.get_cell_atlas_coords(Vector2i(tilex, tiley)) == Vector2i(2, 0):
		obstacles.set_cell(Vector2i(tilex, tiley), 0, Vector2i(1, 0), 0)
	elif obstacles.get_cell_tile_data(Vector2i(tilex, tiley)) != null and obstacles.get_cell_atlas_coords(Vector2i(tilex, tiley)) == Vector2i(1, 0):
		obstacles.set_cell(Vector2i(tilex, tiley), -1, Vector2i(0, 0), 0)
	
	$/root/Main.soldiers.remove_at(0)
	
	$/root/Main/Sfx/Shoot.play()
	
	$/root/Main/Camera2D.zooming_in = false
	
	var soldier_node_path = $/root/Main.current_soldier
	var soldier = $/root/Main.get_node(soldier_node_path)
	soldier.get_node("Buttons").hide()
	soldier.action = ""
	
	for child in $/root/Main/AlliedSoldiers.get_children():
		if child.get_tile_pos().x == tilex and child.get_tile_pos().y == tiley:
			child.knockback = Vector2(-sign(tilex - soldier.get_tile_pos().x), -sign(tiley - soldier.get_tile_pos().y)) * knockback_speed
			child.damage()
	
	for child in $/root/Main/AxisSoldiers.get_children():
		if child.get_tile_pos().x == tilex and child.get_tile_pos().y == tiley:
			child.knockback = Vector2(-sign(tilex - soldier.get_tile_pos().x), -sign(tiley - soldier.get_tile_pos().y)) * knockback_speed
			child.damage()
	
	if len($/root/Main.soldiers) > 0:
		var world_pos = $/root/Main.get_node($/root/Main.soldiers[0]).get_world_pos()
		$/root/Main/Camera2D.start_zooming(world_pos.x, world_pos.y)
	
	var outlines = $/root/Main/Outlines
	for n in outlines.get_children():
		outlines.remove_child(n)
		n.queue_free()
