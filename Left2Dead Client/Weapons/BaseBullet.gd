extends Area2D

export (float) var lifeTime = 1.0
export (float) var speed = 100
export (PackedScene) var particleEffect

var dir = Vector2()
var damage := 0
var knockback := 0

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
	
func init(pos:Vector2, newDamage:int, newKnockback:int, newDir:Vector2):
	position = pos
	setDir(newDir)
	setDamage(newDamage)
	setKnockback(newKnockback)
	look_at(pos + newDir)

func setDamage(newDamage) -> void:
	damage = newDamage
	
func setKnockback(newKnockback) -> void:
	knockback = newKnockback

	
func _onBulletTimeout() -> void:
	queue_free()

func _playParticleEffect() -> void:
	var a = particleEffect.instance()
	a.emitting = true
	a.global_position = global_position
	get_tree().get_root().add_child(a)

func _on_BaseBullet_body_entered(body):
	$Sprite.hide()
	_playParticleEffect()
	$CollisionShape2D.call_deferred("set_disabled", true)
	if body.is_in_group("Players"):
		pass
		# note: can be explored further for friendly fire
	elif body.is_in_group("Enemy"):
		body.rpc_id(-1, "takeDamage", damage, dir, knockback)
