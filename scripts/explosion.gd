extends GPUParticles2D

var time = 0.0

@onready var tilesz = $/root/Main/Map/Tiles.tile_set.tile_size.x

var can_damage_tiles: bool = true

func get_tile_pos() -> Vector2i:
	var px = int(floor(position.x / tilesz))
	var py = int(floor(position.y / tilesz))
	return Vector2i(px, py)

func _ready() -> void:
	emitting = true
	time = 1.0
	$/root/Main/Sfx/Explosion.play()
	
	# Damage nearby soldiers
	var tilepos = get_tile_pos()
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	for x in range(tilepos.x - 2, tilepos.x + 2 + 1):
		for y in range(tilepos.y - 2, tilepos.y + 2 + 1):
			for child in $/root/Main/AlliedSoldiers.get_children():
				if child.get_tile_pos() == Vector2i(x, y):
					child.damage(2)
			for child in $/root/Main/AxisSoldiers.get_children():
				if child.get_tile_pos() == Vector2i(x, y):
					child.damage(2)
			if not can_damage_tiles:
				continue
			if obstacles.get_cell_tile_data(Vector2i(x, y)) == null:
				continue
			if obstacles.get_cell_atlas_coords(Vector2i(x, y)) == Vector2i(2, 0):
				obstacles.set_cell(Vector2i(x, y), 0, Vector2i(1, 0), 0)
			elif obstacles.get_cell_atlas_coords(Vector2i(x, y)) == Vector2i(1, 0):
				obstacles.set_cell(Vector2i(x, y), -1, Vector2i(0, 0), 0)

func _process(delta: float) -> void:
	time -= delta
	if time <= 0.0:
		queue_free()
