extends Sprite2D

@export var explosion: PackedScene

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
	while len($/root/Main.soldiers) > 0 and $/root/Main.get_node_or_null($/root/Main.soldiers[0]) == null:
		$/root/Main.soldiers.remove_at(0)
	
	var e = explosion.instantiate()
	e.position = position
	e.can_damage_tiles = false
	$/root/Main/Sfx/Explosion.play()
	$/root/Main.add_child(e)
	
	$/root/Main/Camera2D.zooming_in = false
	
	var soldier_node_path = $/root/Main.current_soldier
	var soldier = $/root/Main.get_node(soldier_node_path)
	soldier.get_node("Buttons").hide()
	soldier.action = ""
	soldier.startx = soldier.get_tile_pos().x
	soldier.starty = soldier.get_tile_pos().y
	
	if len($/root/Main.soldiers) > 0:
		var world_pos = $/root/Main.get_node($/root/Main.soldiers[0]).get_world_pos()
		$/root/Main/Camera2D.start_zooming(world_pos.x, world_pos.y)
	
	var outlines = $/root/Main/Outlines
	for n in outlines.get_children():
		outlines.remove_child(n)
		n.queue_free()
