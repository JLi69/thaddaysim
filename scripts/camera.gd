extends Camera2D

@export var pan_speed: float = 0.0
@export var min_zoom: float = 1.5
@export var max_zoom: float = 5.0
@onready var default_zoom: float = zoom.x

var zooming_in: bool = false
var zoom_target: Vector2 = Vector2(0.0, 0.0)

const zoom_speed: float = 0.1
const margin_x: float = 320.0

func start_zooming(x: float, y: float):
	zooming_in = true
	zoom_target = Vector2(x, y)

func zoom_in(delta: float) -> void:
	zoom.x += (default_zoom - zoom.x) * delta
	zoom.y = zoom.x
	
	position.x += (zoom_target.x - position.x) * delta
	position.y += (zoom_target.y - position.y) * delta
	
	if (position - zoom_target).length() < 16.0 and abs(zoom.x - default_zoom) < 0.1:
		zooming_in = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("camera_stop_zoom"):
		zooming_in = false
	
	if zooming_in:
		zoom_in(delta)
		return
	
	# Handle input for panning around
	var vx = 0.0
	var vy = 0.0
	if Input.is_action_pressed("camera_up"):
		vy -= 1.0
	if Input.is_action_pressed("camera_down"):
		vy += 1.0
	if Input.is_action_pressed("camera_left"):
		vx -= 1.0
	if Input.is_action_pressed("camera_right"):
		vx += 1.0
		
	if Input.is_action_pressed("camera_move"):
		vx = 0.0
		vy = 0.0
		
	# move
	var direction = Vector2(vx, vy)
	if direction.length() > 0.0:
		direction /= direction.length()
	position += direction * pan_speed * delta * 1.0 / sqrt(zoom.x)
	
	# clamp camera position
	var map_rect: Rect2i = $/root/Main/Map/Tiles.get_used_rect()
	var tile_sz = $/root/Main/Map/Tiles.tile_set.tile_size.x
	var map_rect_pos: Vector2i = map_rect.position * tile_sz
	var map_rect_sz: Vector2i = map_rect.size * tile_sz
	var viewport = (get_viewport_rect().size / zoom) / 2.0
	position.x = clamp(
		position.x, 
		map_rect_pos.x + viewport.x, 
		map_rect_pos.x + map_rect_sz.x + margin_x - viewport.x
	)
	position.y = clamp(
		position.y, 
		map_rect_pos.y + viewport.y,
		map_rect_pos.y + map_rect_sz.y - viewport.y
	)

func _unhandled_input(event: InputEvent) -> void:
	# zoom
	if event.is_action_pressed("zoom_in") and not zooming_in:
		zoom += Vector2(zoom_speed, zoom_speed)
	if event.is_action_pressed("zoom_out") and not zooming_in:
		zoom -= Vector2(zoom_speed, zoom_speed)
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)
	
	if Input.is_action_pressed("camera_move") and event is InputEventMouseMotion and not zooming_in:
		position.x -= event.screen_relative.x / 4.0
		position.y -= event.screen_relative.y / 4.0
