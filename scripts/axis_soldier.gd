extends AnimatedSprite2D

@export var walking_speed: float = 0.0
@export var effect_particles: PackedScene
@export var explosion: PackedScene

@export var show_health: bool = true

var startx: int = 0
var starty: int = 0
var targetx: int = 0
var targety: int = 0
var building: bool = false
var knockback: Vector2 = Vector2.ZERO
@onready var tilesz = $/root/Main/Map/Tiles.tile_set.tile_size.x
var size: Vector2i = Vector2i.ZERO

var action: String = ""

@export var hp: int = 10
@export var max_hp: int = 10

func damage(amt: int = 1):
	var particles = effect_particles.instantiate()
	particles.modulate = Color.RED
	particles.position = position
	$/root/Main.add_child(particles)
	$/root/Main/Sfx/Grunt.play()
	hp -= amt
	if hp <= 0:
		queue_free()

func get_tile_pos() -> Vector2i:
	var px = int(floor(position.x / tilesz))
	var py = int(floor((position.y + size.y / 2.0 - size.y / 8.0) / tilesz))
	return Vector2i(px, py)

func get_world_pos() -> Vector2:
	var tile_pos = get_tile_pos()
	var px = tile_pos.x * tilesz + tilesz / 2.0
	var py = tile_pos.y * tilesz + tilesz / 2.0 - size.y / 2.0 + size.y / 8.0
	return Vector2(px, py)
	
func space_occupied(px: int, py: int, dx: int, dy: int) -> bool:
	for child in $/root/Main/AlliedSoldiers.get_children():
		if child.get_tile_pos() == Vector2i(px + dx, py + dy):
			return true
	return false
	
func can_move(px: int, py: int, dx: int, dy: int) -> bool:
	var pos = Vector2(px + 0.5, py + 0.5)
	var d = Vector2(dx, dy)
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	if obstacles.get_cell_tile_data(Vector2i(px + dx, py + dy)) != null and obstacles.get_cell_tile_data(Vector2i(px + dx, py + dy)).get_custom_data("wall"):
		return false
	if d.length() == 0.0:
		return true
	while d.length() > 0.1:
		var dist = min(d.length(), 0.1)
		var diff = d / d.length() * dist
		d -= diff
		pos += diff
		if obstacles.get_cell_tile_data(Vector2i(floor(pos.x), floor(pos.y))) == null:
			continue
		if obstacles.get_cell_tile_data(Vector2i(floor(pos.x), floor(pos.y))).get_custom_data("wall"):
			return false
	return true

func get_possible_moves() -> Array[Vector2i]:
	var possible: Array[Vector2i] = []
	var p = get_tile_pos()
	var tilemap: TileMapLayer = $/root/Main/Map/Tiles
	
	for x in range(-6, 6 + 1):
		for y in range(-6, 6 + 1):
			if x == 0 and y == 0:
				continue
			var pos = p + Vector2i(x, y)
			if tilemap.get_cell_tile_data(pos) == null:
				continue
			if tilemap.get_cell_tile_data(pos).get_custom_data("unwalkable"):
				continue
			if not can_move(p.x, p.y, x, y):
				continue
			if space_occupied(p.x, p.y, x, y):
				continue
			possible.append(pos)
	
	return possible

func can_build(px: int, py: int, dx: int, dy: int) -> bool:
	var pos = Vector2(px + 0.5, py + 0.5)
	var d = Vector2(dx, dy)
	if d.length() == 0.0:
		return true
	
	for child in $/root/Main/AxisSoldiers.get_children():
		if child.get_tile_pos() == Vector2i(px, py) and child.name != name:
			return false
	for child in $/root/Main/AlliedSoldiers.get_children():
		if child.get_tile_pos() == Vector2i(px, py):
			return false
	if $/root/Main/Flag.get_tile_pos() == Vector2i(px, py):
		return false
	
	var obstacles = $/root/Main/Map/Obstacles
	
	while d.length() > 0.1:
		var dist = min(d.length(), 0.1)
		var diff = d / d.length() * dist
		d -= diff
		pos += diff
		
		var tilex = int(floor(pos.x))
		var tiley = int(floor(pos.y))
		
		if obstacles.get_cell_tile_data(Vector2i(tilex, tiley)) != null and obstacles.get_cell_tile_data(Vector2i(tilex, tiley)).get_custom_data("landmine"):
			return false
		
		if $/root/Main/Flag.get_tile_pos() == Vector2i(tilex, tiley):
			return false
		
		for child in $/root/Main/AxisSoldiers.get_children():
			if child.get_tile_pos() == Vector2i(tilex, tiley) and child.name != name:
				return false
		for child in $/root/Main/AlliedSoldiers.get_children():
			if child.get_tile_pos() == Vector2i(tilex, tiley):
				return false
	return true

func get_possible_build() -> Array[Vector2i]:
	var possible: Array[Vector2i] = []
	var p = get_tile_pos()
	var tilemap: TileMapLayer = $/root/Main/Map/Tiles
	
	for x in range(-3, 3 + 1):
		for y in range(-3, 3 + 1):
			var pos = p + Vector2i(x, y)
			if x == 0 and y == 0:
				continue
			if tilemap.get_cell_tile_data(pos) == null:
				continue
			if tilemap.get_cell_tile_data(pos).get_custom_data("unwalkable"):
				continue
			if not can_move(p.x, p.y, x, y):
				continue
			if not can_build(p.x, p.y, x, y):
				continue
			possible.append(pos)
	
	return possible

func get_possible_landmines() -> Array[Vector2i]:
	var possible: Array[Vector2i] = []
	var p = get_tile_pos()
	var tilemap: TileMapLayer = $/root/Main/Map/Tiles
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	
	for x in range(-1, 1 + 1):
		for y in range(-1, 1 + 1):
			if abs(x) + abs(y) > 1 or (x == 0 and y == 0):
				continue
			var pos = p + Vector2i(x, y)
			if tilemap.get_cell_tile_data(pos) == null:
				continue
			if tilemap.get_cell_tile_data(pos).get_custom_data("unwalkable"):
				continue
			if obstacles.get_cell_tile_data(pos) != null and obstacles.get_cell_tile_data(pos).get_custom_data("wall"):
				continue
			if obstacles.get_cell_tile_data(pos) != null and obstacles.get_cell_tile_data(pos).get_custom_data("landmine"):
				continue
			if not can_move(p.x, p.y, x, y):
				continue
			if $/root/Main/Flag.get_tile_pos() == pos:
				continue
			possible.append(pos)
	
	return possible

func get_possible_shoot():
	var possible: Array[Vector2i] = []
	var p = get_tile_pos()
	# Axis soldiers have a slightly larger range for shooting
	for x in range(-4, 4 + 1):
		if x == 0:
			continue
		if can_move(p.x, p.y, x, 0) or can_move(p.x, p.y, x - sign(x), 0):
			possible.push_back(p + Vector2i(x, 0))
		if can_move(p.x, p.y, 0, x) or can_move(p.x, p.y, 0, x - sign(x)):
			possible.push_back(p + Vector2i(0, x))
	
	return possible

func _ready() -> void:
	if not show_health:
		$Heart.hide()
	
	var fsize = sprite_frames.get_frame_texture("default", 0).get_size()
	size = fsize
	# Lock the position of the tile grid
	position = get_world_pos()
	targetx = get_tile_pos().x
	targety = get_tile_pos().y
	startx = get_tile_pos().x
	starty = get_tile_pos().y
	
	$Buttons.hide()

func handle_knockback(delta: float) -> void:
	# Handle knockback
	if knockback.length() == 0.0:
		return
	
	if abs(knockback.x) > 0.05:
		knockback.x -= sign(knockback.x) * delta * 32.0
	else:
		knockback.x = 0.0
	
	if abs(knockback.y) > 0.05:
		knockback.y -= sign(knockback.y) * delta * 32.0
	else:
		knockback.y = 0.0
	
	if knockback.length() == 0:
		var tilepos = get_tile_pos()
		targetx = tilepos.x
		targety = tilepos.y
		startx = tilepos.x
		starty = tilepos.y
	
	position -= knockback * delta
	var tpos = get_tile_pos() # Tile position
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	if obstacles.get_cell_tile_data(tpos) != null and obstacles.get_cell_tile_data(tpos).get_custom_data("wall"):
		position += knockback * delta
		position = get_world_pos()
		knockback = Vector2.ZERO
		var tilepos = get_tile_pos()
		targetx = tilepos.x
		targety = tilepos.y
		startx = tilepos.x
		starty = tilepos.y
		return
	var tilemap: TileMapLayer = $/root/Main/Map/Tiles
	if tilemap.get_cell_tile_data(tpos) == null:
		position += knockback * delta
		position = get_world_pos()
		knockback = Vector2.ZERO
		var tilepos = get_tile_pos()
		targetx = tilepos.x
		targety = tilepos.y
		startx = tilepos.x
		starty = tilepos.y
		return
	if tilemap.get_cell_tile_data(tpos).get_custom_data("unwalkable"):
		position += knockback * delta
		position = get_world_pos()
		knockback = Vector2.ZERO
		var tilepos = get_tile_pos()
		targetx = tilepos.x
		targety = tilepos.y
		startx = tilepos.x
		starty = tilepos.y
		return

func check_if_step_on_landmine():
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	var tilepos = get_tile_pos()
	if obstacles.get_cell_tile_data(tilepos) == null:
		return
	if obstacles.get_cell_tile_data(tilepos).get_custom_data("landmine"):
		obstacles.set_cell(tilepos, -1, Vector2i(0, 0), 0)
		var e = explosion.instantiate()
		e.position = get_world_pos() + Vector2(0.0, size.y / 2.0 - size.y / 8.0)
		$/root/Main.add_child(e)

func _process(delta: float) -> void:
	# set health text
	$Heart/HP.text = str(hp) + "/" + str(max_hp)
	
	var tilepos = get_tile_pos()
	
	check_if_step_on_landmine()
	
	# Build
	if building and not (tilepos.x == targetx and tilepos.y == targety):
		var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
		if obstacles.get_cell_tile_data(Vector2i(tilepos.x, tilepos.y)) == null:
			obstacles.set_cell(Vector2i(tilepos.x, tilepos.y), 0, Vector2i(2, 0), 0)
	elif building and (tilepos.x == targetx and tilepos.y == targety):
		building = false
	
	var target = Vector2(targetx, targety) * tilesz + Vector2(tilesz / 2.0, tilesz / 2.0 - size.y / 2.0 + size.y / 8.0)
	var vel = Vector2.ZERO
	
	if abs(position.x - target.x) < 3.0 and knockback.length() == 0.0:
		position.x = target.x
	if abs(position.y - target.y) < 3.0 and knockback.length() == 0.0:
		position.y = target.y
	
	var dist = (target - position).length()
	if dist > 0 and knockback.length() == 0.0:
		vel.x = (target.x - position.x) / dist
		if vel.x < 0.0:
			flip_h = true
		else:
			flip_h = false
		vel.y = (target.y - position.y) / dist
	
	# move
	var d = clamp(delta * walking_speed, 0.0, 1.0)
	position += vel * d
	
	if abs(position.x - target.x) < 4.0 and abs(position.y - target.y) < 4.0 and knockback.length() == 0.0:
		tilepos = get_tile_pos()
		targetx = tilepos.x
		targety = tilepos.y
		startx = tilepos.x
		starty = tilepos.y
		if animation != "default":
			animation = "default"
		position = get_world_pos()
	
	handle_knockback(delta)
