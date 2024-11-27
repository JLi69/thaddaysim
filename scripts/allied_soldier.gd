extends AnimatedSprite2D

@export var effect_particles: PackedScene
@export var explosion: PackedScene

@export var walking_speed: float = 0.0
@export var show_health: bool = true

var startx: int = 0
var starty: int = 0
var targetx: int = 0
var targety: int = 0
var knockback: Vector2 = Vector2.ZERO
@onready var tilesz = $/root/Main/Map/Tiles.tile_set.tile_size.x
var size: Vector2i = Vector2i.ZERO

var action: String = ""

@export var hp: int = 8
@export var max_hp: int = 8

func damage(amt: int = 1):
	var particles = effect_particles.instantiate()
	particles.modulate = Color.RED
	particles.position = position
	$/root/Main.add_child(particles)
	$/root/Main/Sfx/Grunt.play()
	hp -= amt
	if hp <= 0:
		queue_free()

func heal():
	if hp < max_hp:
		var particles = effect_particles.instantiate()
		particles.modulate = Color.LIME_GREEN
		particles.position = position
		$/root/Main.add_child(particles)
		$/root/Main/Sfx/Heal.play()
	hp += 1
	hp = min(max_hp, hp)

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

func space_occupied(px: int, py: int, dx: int, dy: int) -> bool:
	for child in $/root/Main/AxisSoldiers.get_children():
		if child.get_tile_pos() == Vector2i(px + dx, py + dy):
			return true
	return false

func get_possible_moves() -> Array[Vector2i]:
	var possible: Array[Vector2i] = []
	var p = get_tile_pos()
	var tilemap: TileMapLayer = $/root/Main/Map/Tiles
	
	for x in range(-4, 4 + 1):
		for y in range(-4, 4 + 1):
			if x == 0 and y == 0:
				continue
			var pos = p + Vector2i(x, y)
			if tilemap.get_cell_tile_data(pos) == null:
				continue
			if tilemap.get_cell_tile_data(pos).get_custom_data("unwalkable"):
				continue
			if (not can_move_xy(p.x, p.y, x, y)) and (not can_move_yx(p.x, p.y, x, y)):
				continue
			if space_occupied(p.x, p.y, x, y):
				continue
			possible.append(pos)
	
	return possible

func get_possible_heal() -> Array[Vector2i]:
	var possible: Array[Vector2i] = []
	var p = get_tile_pos()
	for x in range(-2, 2 + 1):
		if x == 0:
			continue
		if can_move_xy(p.x, p.y, x, 0):
			possible.push_back(p + Vector2i(x, 0))
		if can_move_xy(p.x, p.y, 0, x):
			possible.push_back(p + Vector2i(0, x))
	
	return possible

func get_possible_shoot() -> Array[Vector2i]:
	var possible: Array[Vector2i] = []
	var p = get_tile_pos()
	for x in range(-3, 3 + 1):
		if x == 0:
			continue
		if can_move_xy(p.x, p.y, x, 0) or can_move_xy(p.x, p.y, x - sign(x), 0):
			possible.push_back(p + Vector2i(x, 0))
		if can_move_xy(p.x, p.y, 0, x) or can_move_xy(p.x, p.y, 0, x - sign(x)):
			possible.push_back(p + Vector2i(0, x))
	
	return possible

func can_grenade(pos: Vector2i, diff: Vector2i, dist: int) -> bool:
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	for i in range(0, dist + 1):
		var p = pos + diff * i
		if obstacles.get_cell_tile_data(p) != null and obstacles.get_cell_tile_data(p).get_custom_data("wall"):
			return false
	return true

func get_possible_grenade() -> Array[Vector2i]:
	var possible: Array[Vector2i] = []
	var p = get_tile_pos()
	var dist = 4
	var diff = [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]
	for d in diff:
		if not can_grenade(p, d, dist):
			continue
		possible.push_back(p + d * dist)
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
	
	position -= knockback * delta
	var tpos = get_tile_pos() # Tile position
	var obstacles: TileMapLayer = $/root/Main/Map/Obstacles
	if obstacles.get_cell_tile_data(tpos) != null and obstacles.get_cell_tile_data(tpos).get_custom_data("wall"):
		position += knockback * delta
		position = get_world_pos()
		knockback = Vector2.ZERO
		return
	var tilemap: TileMapLayer = $/root/Main/Map/Tiles
	if tilemap.get_cell_tile_data(tpos) == null:
		position += knockback * delta
		position = get_world_pos()
		knockback = Vector2.ZERO
		return
	if tilemap.get_cell_tile_data(tpos).get_custom_data("unwalkable"):
		position += knockback * delta
		position = get_world_pos()
		knockback = Vector2.ZERO
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
	
	var diff = Vector2i(targetx - startx, targety - starty)
	var target = Vector2(targetx, targety) * tilesz + Vector2(tilesz / 2.0, tilesz / 2.0 - size.y / 2.0 + size.y / 8.0)
	var vel = Vector2.ZERO
	
	if abs(position.x - target.x) < 3.0 and knockback.length() == 0.0:
		position.x = target.x
	if abs(position.y - target.y) < 3.0 and knockback.length() == 0.0:
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
	elif knockback.length() == 0.0:
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
