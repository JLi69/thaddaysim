extends Node2D

@export var white_outline: PackedScene

@onready var tilesz: int = $Map/Tiles.tile_set.tile_size.x;
var soldiers = []
var current_soldier: String = ""

func convert_tile_to_world(p: Vector2i) -> Vector2:
	return Vector2(p.x, p.y) * tilesz + Vector2(tilesz / 2, tilesz / 2)
	
func add_soldiers_to_queue(node: Node2D, path: String):
	for s in node.get_children():
		if s.animation != "default":
			return
	
	for s in node.get_children():
		soldiers.append(path + s.name)

func _ready() -> void:
	# Allied soldiers go first
	add_soldiers_to_queue($AlliedSoldiers, "AlliedSoldiers/")
		
func generate_outlines():
	if len(soldiers) == 0:
		return
	
	var node_name = soldiers[0]
	current_soldier = node_name
	var pos = get_node(node_name).get_tile_pos()
	$GreenOutline.position = convert_tile_to_world(pos)
	
	if $Outlines.get_child_count() == 0:
		var possible = get_node(node_name).get_possible_moves()
		for p in possible:
			var outline = white_outline.instantiate()
			outline.tilex = p.x
			outline.tiley = p.y
			outline.position = convert_tile_to_world(p)
			$Outlines.add_child(outline)

func _process(_delta: float) -> void:
	generate_outlines()
	
	if len(soldiers) == 0:
		add_soldiers_to_queue($AlliedSoldiers, "AlliedSoldiers/")
	
	if len(soldiers) == 0:
		$GreenOutline.hide()
	else:
		$GreenOutline.show()
