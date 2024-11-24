extends Node2D

@export var white_outline: PackedScene
@export var landmine_outline: PackedScene
@export var heal_outline: PackedScene
@export var shoot_outline: PackedScene
@export var build_outline: PackedScene

@onready var tilesz: int = $Map/Tiles.tile_set.tile_size.x;
var soldiers = []
var current_soldier: String = ""
var node_paths = [ "AlliedSoldiers/", "AxisSoldiers/" ]
# 0 = allies, 1 = axis
var current_turn: int = 0

func convert_tile_to_world(p: Vector2i) -> Vector2:
	return Vector2(p.x, p.y) * tilesz + Vector2(tilesz / 2, tilesz / 2)
	
func add_soldiers_to_queue(node: Node2D, path: String):
	for p in node_paths:
		for s in get_node(p).get_children():
			if s.animation != "default":
				current_turn -= 1
				current_turn %= len(node_paths)
				return
	
	for s in node.get_children():
		if not s.visible:
			continue
		soldiers.append(path + s.name)

func _ready() -> void:
	# Allied soldiers go first
	add_soldiers_to_queue(get_node(node_paths[current_turn]), node_paths[current_turn])
	# center camera upon soldier
	if len(soldiers) != 0:
		$Camera2D.position = get_node(soldiers[0]).position
		$Camera2D.position.y += get_node(soldiers[0]).size.y / 8.0 * 3.0

func add_outline(scene: PackedScene, p: Vector2i):
	var outline = scene.instantiate()
	outline.tilex = p.x
	outline.tiley = p.y
	outline.position = convert_tile_to_world(p)
	$Outlines.add_child(outline)

func generate_outlines():
	if len(soldiers) == 0:
		return
	
	current_soldier = soldiers[0]
	var soldier = get_node(current_soldier)
	var pos = soldier.get_tile_pos()
	var world_pos = convert_tile_to_world(pos)
	$GreenOutline.position = world_pos
	
	if soldier.action == "":
		soldier.get_node("Buttons").show()
		
	if $Outlines.get_child_count() > 0:
		return
	
	match soldier.action:
		"move":
			var possible = soldier.get_possible_moves()
			for p in possible:
				add_outline(white_outline, p)
		"landmine":
			var possible = soldier.get_possible_landmines()
			for p in possible:
				add_outline(landmine_outline, p)
		"heal":
			var possible = soldier.get_possible_heal()
			for p in possible:
				add_outline(heal_outline, p)
		"shoot":
			var possible = soldier.get_possible_shoot()
			for p in possible:
				add_outline(shoot_outline, p)
		"build":
			var possible = soldier.get_possible_build()
			for p in possible:
				add_outline(build_outline, p)
		_:
			pass

func _process(_delta: float) -> void:
	generate_outlines()
	
	if Input.is_action_pressed("cancel") and len(soldiers) > 0:
		var soldier = get_node(soldiers[0])
		soldier.action = ""
		soldier.get_node("Buttons").show()
		for child in $Outlines.get_children():
			$Outlines.remove_child(child)
			child.queue_free()
	
	if len(soldiers) == 0:
		current_turn += 1
		current_turn %= len(node_paths)
		add_soldiers_to_queue(get_node(node_paths[current_turn]), node_paths[current_turn])
		if len(soldiers) > 0:
			var world_pos = get_node(soldiers[0]).get_world_pos()
			$Camera2D.start_zooming(world_pos.x, world_pos.y)
	
	if len(soldiers) == 0:
		$GreenOutline.hide()
	else:
		current_soldier = soldiers[0]
		var soldier = get_node(current_soldier)
		var pos = soldier.get_tile_pos()
		var world_pos = convert_tile_to_world(pos)
		$GreenOutline.position = world_pos
		$GreenOutline.show()
