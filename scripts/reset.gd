extends Node2D

@onready var camera: Camera2D = $/root/Main/Camera2D.duplicate()
@onready var map: Node2D = $/root/Main/Map.duplicate()

var allied_soldiers = []
var axis_soldiers = []

func _ready() -> void:
	for child in $/root/Main/AlliedSoldiers.get_children():
		allied_soldiers.append(child.duplicate())
	for child in $/root/Main/AxisSoldiers.get_children():
		axis_soldiers.append(child.duplicate())

func reset() -> void:
	# Reset flag
	$/root/Main/Flag.captured = false
	
	# Reset camera
	var old_camera = $/root/Main.get_node("Camera2D")
	$/root/Main.remove_child(old_camera)
	old_camera.queue_free()
	$/root/Main.add_child(camera.duplicate())
	
	# Reset map
	var old_map = $/root/Main.get_node("Map")
	$/root/Main.remove_child(old_map)
	old_map.queue_free()
	$/root/Main.add_child(map.duplicate())
	
	# Reset outlines
	for child in $/root/Main/Outlines.get_children():
		$/root/Main/Outlines.remove_child(child)
		child.queue_free()
	
	# Reset allied soldiers
	for child in $/root/Main/AlliedSoldiers.get_children():
		$/root/Main/AlliedSoldiers.remove_child(child)
		child.queue_free()
	for soldier in allied_soldiers:
		$/root/Main/AlliedSoldiers.add_child(soldier.duplicate())
	
	# Reset axis soldiers
	for child in $/root/Main/AxisSoldiers.get_children():
		$/root/Main/AxisSoldiers.remove_child(child)
		child.queue_free()
	for soldier in axis_soldiers:
		$/root/Main/AxisSoldiers.add_child(soldier.duplicate())
	
	# Reset Main
	$/root/Main.game_over = false
	$/root/Main.current_turn = 0
	$/root/Main.soldiers = []
	$/root/Main.current_soldier = ""
	# Allied soldiers go first
	var current = $/root/Main.node_paths[$/root/Main.current_turn]
	var node = $/root/Main.get_node(current)
	$/root/Main.add_soldiers_to_queue(node, current)
	# center camera upon soldier
	if len($/root/Main.soldiers) != 0:
		var soldier_node = $/root/Main.get_node($/root/Main.soldiers[0])
		$/root/Main/Camera2D.position = soldier_node.position
		$/root/Main/Camera2D.position.y += soldier_node.size.y / 8.0 * 3.0
		
	# Remove particle effects
	for child in $/root/Main.get_children():
		if child is GPUParticles2D:
			$/root/Main.remove_child(child)
			child.queue_free()
