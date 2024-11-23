extends AnimatedSprite2D

@export var walking_speed: float = 0.0

var startx: int = 0
var starty: int = 0
var targetx: int = 0
var targety: int = 0
@onready var tilesz = $/root/Main/Map/Tiles.tile_set.tile_size.x
var size: Vector2i = Vector2i.ZERO

var action: String = ""

func get_tile_pos() -> Vector2i:
	var px = int(floor(position.x / tilesz))
	var py = int(floor((position.y + size.y / 2.0 - size.y / 8.0) / tilesz))
	return Vector2i(px, py)

func get_world_pos() -> Vector2:
	var tile_pos = get_tile_pos()
	var px = tile_pos.x * tilesz + tilesz / 2.0
	var py = tile_pos.y * tilesz + tilesz / 2.0 - size.y / 2.0 + size.y / 8.0
	return Vector2(px, py)
	
func can_move_xy(px: int, py: int, dx: int, dy: int) -> bool:
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	var tiles: TileMapLayer = $/root/Main/Map/Tiles
	var p = Vector2i(px, py)
	
	while p.x != px + dx:
		if p.x > px + dx:
			p.x -= 1
		elif p.x < px + dx:
			p.x += 1
		
		if tiles.get_cell_tile_data(p) == null:
			return false
		if tiles.get_cell_tile_data(p).get_custom_data("unwalkable"):
			return false
		
		if obstacles.get_cell_tile_data(p) == null:
			continue
		if obstacles.get_cell_tile_data(p).get_custom_data("wall"):
			return false
			
	while p.y != py + dy:
		if p.y > py + dy:
			p.y -= 1
		elif p.y < py + dy:
			p.y += 1
		
		if tiles.get_cell_tile_data(p) == null:
			return false
		if tiles.get_cell_tile_data(p).get_custom_data("unwalkable"):
			return false
		
		if obstacles.get_cell_tile_data(p) == null:
			continue
		if obstacles.get_cell_tile_data(p).get_custom_data("wall"):
			return false
	
	return true
	
func count_landmines_xy(px: int, py: int, dx: int, dy: int) -> int:
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	var p = Vector2i(px, py)
	var count = 0
	
	while p.x != px + dx:
		if p.x > px + dx:
			p.x -= 1
		elif p.x < px + dx:
			p.x += 1
		
		if obstacles.get_cell_tile_data(p) == null:
			continue
		if obstacles.get_cell_tile_data(p).get_custom_data("landmine"):
			count += 1
			
	while p.y != py + dy:
		if p.y > py + dy:
			p.y -= 1
		elif p.y < py + dy:
			p.y += 1
		
		if obstacles.get_cell_tile_data(p) == null:
			continue
		if obstacles.get_cell_tile_data(p).get_custom_data("landmine"):
			count += 1
	
	return count
	
func can_move_yx(px: int, py: int, dx: int, dy: int) -> bool:
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	var tiles: TileMapLayer = $/root/Main/Map/Tiles
	var p = Vector2i(px, py)
	
	while p.y != py + dy:
		if p.y > py + dy:
			p.y -= 1
		elif p.y < py + dy:
			p.y += 1
			
		if tiles.get_cell_tile_data(p) == null:
			return false
		if tiles.get_cell_tile_data(p).get_custom_data("unwalkable"):
			return false
		
		if obstacles.get_cell_tile_data(p) == null:
			continue
		if obstacles.get_cell_tile_data(p).get_custom_data("wall"):
			return false
			
	while p.x != px + dx:
		if p.x > px + dx:
			p.x -= 1
		elif p.x < px + dx:
			p.x += 1
		
		if tiles.get_cell_tile_data(p) == null:
			return false
		if tiles.get_cell_tile_data(p).get_custom_data("unwalkable"):
			return false
		
		if obstacles.get_cell_tile_data(p) == null:
			continue
		if obstacles.get_cell_tile_data(p).get_custom_data("wall"):
			return false
	
	return true

func count_landmines_yx(px: int, py: int, dx: int, dy: int) -> int:
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	var p = Vector2i(px, py)
	var count = 0
	
	while p.y != py + dy:
		if p.y > py + dy:
			p.y -= 1
		elif p.y < py + dy:
			p.y += 1
		
		if obstacles.get_cell_tile_data(p) == null:
			continue
		if obstacles.get_cell_tile_data(p).get_custom_data("landmine"):
			count += 1
	
	while p.x != px + dx:
		if p.x > px + dx:
			p.x -= 1
		elif p.x < px + dx:
			p.x += 1
		
		if obstacles.get_cell_tile_data(p) == null:
			continue
		if obstacles.get_cell_tile_data(p).get_custom_data("landmine"):
			count += 1
	
	return count

func get_possible_moves() -> Array[Vector2i]:
	var possible: Array[Vector2i] = []
	var p = get_tile_pos()
	var tilemap: TileMapLayer = $/root/Main/Map/Tiles
	
	for x in range(-6, 6 + 1):
		for y in range(-6, 6 + 1):
			if abs(x) + abs(y) > 6 or (x == 0 and y == 0):
				continue
			var pos = p + Vector2i(x, y)
			if tilemap.get_cell_tile_data(pos) == null:
				continue
			if tilemap.get_cell_tile_data(pos).get_custom_data("unwalkable"):
				continue
			if (not can_move_xy(p.x, p.y, x, y)) and (not can_move_yx(p.x, p.y, x, y)):
				continue
			possible.append(pos)
	
	return possible

func _ready() -> void:
	var fsize = sprite_frames.get_frame_texture("default", 0).get_size()
	size = fsize
	# Lock the position of the tile grid
	position = get_world_pos()
	targetx = get_tile_pos().x
	targety = get_tile_pos().y
	startx = get_tile_pos().x
	starty = get_tile_pos().y
	$Buttons.hide()
	
func _process(delta: float) -> void:
	var tilepos = get_tile_pos()
	
	var diff = Vector2i(targetx - startx, targety - starty)
	var target = Vector2(targetx, targety) * tilesz + Vector2(tilesz / 2.0, tilesz / 2.0 - size.y / 2.0 + size.y / 8.0)
	var vel = Vector2.ZERO
	
	if abs(position.x - target.x) < 3.0:
		position.x = target.x
	if abs(position.y - target.y) < 3.0:
		position.y = target.y
	
	if can_move_xy(startx, starty, diff.x, diff.y) and count_landmines_xy(startx, starty, diff.x, diff.y) <= count_landmines_yx(startx, starty, diff.x, diff.y) and diff.length() != 0:
		animation = "walking"
		if position.x < target.x:
			flip_h = false
			vel.x = 1.0
		elif position.x > target.x:
			flip_h = true
			vel.x = -1.0
		elif position.y < target.y:
			vel.y = 1.0
		elif position.y > target.y:
			vel.y = -1.0
	elif can_move_yx(startx, starty, diff.x, diff.y) and count_landmines_xy(startx, starty, diff.x, diff.y) >= count_landmines_yx(startx, starty, diff.x, diff.y) and diff.length() != 0:
		animation = "walking"
		if position.y < target.y:
			vel.y = 1.0
		elif position.y > target.y:
			vel.y = -1.0
		elif position.x < target.x:
			flip_h = false
			vel.x = 1.0
		elif position.x > target.x:
			flip_h = true
			vel.x = -1.0
	else:
		targetx = tilepos.x
		targety = tilepos.y
		startx = tilepos.x
		starty = tilepos.y
		if animation != "default":
			animation = "default"
		position = get_world_pos()
	
	# move
	var d = clamp(delta * walking_speed, 0.0, 1.0)
	position += vel * d
	
	if abs(position.x - target.x) < 4.0 and abs(position.y - target.y) < 4.0:
		tilepos = get_tile_pos()
		targetx = tilepos.x
		targety = tilepos.y
		startx = tilepos.x
		starty = tilepos.y
		if animation != "default":
			animation = "default"
		position = get_world_pos()
