extends AnimatedSprite2D

var captured: bool = false
@onready var tilesz = $/root/Main/Map/Tiles.tile_set.tile_size.x
var size: Vector2i = Vector2i.ZERO

func get_tile_pos() -> Vector2i:
	var px = int(floor((position.x - size.x / 8.0 * 3.0) / tilesz))
	var py = int(floor((position.y + size.y / 2.0) / tilesz))
	return Vector2i(px, py)

func get_world_pos() -> Vector2:
	var tile_pos = get_tile_pos()
	var px = tile_pos.x * tilesz + tilesz / 2.0 + size.x / 8.0 * 3.0
	var py = tile_pos.y * tilesz + tilesz / 2.0 - size.y / 2.0
	return Vector2(px, py)

func _ready() -> void:
	size = sprite_frames.get_frame_texture("default", 0).get_size()
	position = get_world_pos()

func _process(_delta: float) -> void:
	if captured:
		return
	
	# Check if captured
	for child in $/root/Main/AlliedSoldiers.get_children():
		if child.get_tile_pos() == get_tile_pos() and child.animation == "default":
			captured = true
			return
