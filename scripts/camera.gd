extends Camera2D

@export var pan_speed: float = 0.0
@export var min_zoom: float = 1.5
@export var max_zoom: float = 6.0

const zoom_speed: float = 0.1

func _process(delta: float) -> void:
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
		
	# move
	var direction = Vector2(vx, vy)
	if direction.length() > 0.0:
		direction /= direction.length()
	position += direction * pan_speed * delta
	
func _unhandled_input(event: InputEvent) -> void:
	# zoom
	if event.is_action_pressed("zoom_in"):
		zoom += Vector2(zoom_speed, zoom_speed)
	if event.is_action_pressed("zoom_out"):
		zoom -= Vector2(zoom_speed, zoom_speed)
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)
