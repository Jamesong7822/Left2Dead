extends Node2D

export (float) var fireRate = 0.5
export (int) var count = 1
export (float) var spread
export (PackedScene) var Bullet

var canFire = true

func _ready():
	pass
	$Timer.wait_time = fireRate

remote func fire(firePos, fireAt) -> void:
	if canFire:
		if $Timer.is_stopped():
			$Timer.start()
		canFire = false
		for i in range(count):
			var b = Bullet.instance()
			b.position = firePos
			var fireDir = (fireAt - firePos).normalized()
			# spread firedir 
			fireDir = fireDir.rotated((randf()*2-1)*spread)
			b.setDir(fireDir)
			get_tree().get_root().add_child(b)
			b.look_at(firePos + fireDir)
		


func _on_Timer_timeout():
	canFire = true
