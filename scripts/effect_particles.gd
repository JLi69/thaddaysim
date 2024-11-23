extends GPUParticles2D

var time: float = 0.0

func _ready() -> void:
	emitting = true
	time = 1.0

func _process(delta: float) -> void:
	time -= delta
	
	if time <= 0.0:
		queue_free()
