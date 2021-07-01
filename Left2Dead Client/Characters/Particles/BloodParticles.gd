extends Particles2D


func _ready():
	pass

func _process(delta):
	if emitting == false:
		queue_free()
