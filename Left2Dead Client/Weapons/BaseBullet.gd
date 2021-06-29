extends Area2D

export (float) var lifeTime = 1.0
export (float) var speed = 100

var dir = Vector2()

func _ready():
	pass
	var t = Timer.new()
	t.wait_time = lifeTime
	t.autostart = true
	t.connect("timeout", self, "_onBulletTimeout")
	add_child(t)
	
func _physics_process(delta):
	position += dir*speed
		
func setDir(newDir):
	dir = newDir

	
func _onBulletTimeout() -> void:
	queue_free()


func _on_BaseBullet_body_entered(body):
	hide()
	if body.is_in_group("Players"):
		pass
		# note: can be explored further for friendly fire
