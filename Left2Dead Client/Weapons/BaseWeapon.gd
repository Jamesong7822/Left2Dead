extends Node2D

export (String) var weaponName
export (int) var damage
export (int) var knockback
export (float) var fireRate = 0.5
export (int) var count = 1
export (float) var spread
export (PackedScene) var Bullet
export (int) var clipSize
export (int) var totalAmmo

var canFire = true
var currentClip
var currentAmmo
var id = 0

signal update_weapon_hud

func _ready():
	pass
	$Timer.wait_time = fireRate
	currentClip = clipSize
	currentAmmo = totalAmmo
	id = get_tree().get_network_unique_id()
	
	
func _playSFX():
	$FireSFX.play()

func _playReloadSFX():
	$ReloadSFX.play()
	
func _reload() -> void:
	canFire = false
	$Timer.stop()
	_playReloadSFX()

remotesync func fire(firePos, fireAt, from) -> void:
	if canFire and currentClip > 0:
		currentClip -= 1
		if currentClip == 0:
			_reload()
		if $Timer.is_stopped():
			$Timer.start()
		canFire = false
		for _i in range(count):
			var b = Bullet.instance()
			get_tree().get_root().add_child(b)
			var fireDir = (fireAt - firePos).normalized()
			# spread firedir 
			fireDir = fireDir.rotated((randf()*2-1)*spread)
			if from == id:
				b.init(firePos, damage, knockback, fireDir)
			else:
				b.init(firePos, 0, 0, fireDir)
		_playSFX()
		emit_signal("update_weapon_hud", currentClip, currentAmmo)
			
func _on_Timer_timeout():
	canFire = true


func _on_ReloadSFX_finished():
	var refillAmount = clipSize - currentClip
	currentClip = clipSize
	currentAmmo -= refillAmount
	canFire = true
	emit_signal("update_weapon_hud", currentClip, currentAmmo)
