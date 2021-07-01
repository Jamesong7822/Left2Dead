extends Node2D

export (int) var damage
export (int) var knockback
export (float) var fireRate = 0.5
export (int) var count = 1
export (float) var spread
export (PackedScene) var Bullet

var canFire = true

func _ready():
	pass
	$Timer.wait_time = fireRate

func fire(firePos, fireAt) -> void:
	if canFire:
		if $Timer.is_stopped():
			$Timer.start()
		canFire = false
		for _i in range(count):
			var b = Bullet.instance()
			get_tree().get_root().add_child(b)
			var fireDir = (fireAt - firePos).normalized()
			# spread firedir 
			fireDir = fireDir.rotated((randf()*2-1)*spread)
			b.init(firePos, damage, knockback, fireDir)
			
remote func syncFire(firePos, fireAt) -> void:
	if canFire:
		if $Timer.is_stopped():
			$Timer.start()
		canFire = false
		for _i in range(count):
			var b = Bullet.instance()
			get_tree().get_root().add_child(b)
			var fireDir = (fireAt - firePos).normalized()
			# spread firedir 
			fireDir = fireDir.rotated((randf()*2-1)*spread)
			# if not u owning the bullet, we remove both dmg n knockback force
			b.init(firePos, 0, 0, fireDir)

func _on_Timer_timeout():
	canFire = true
