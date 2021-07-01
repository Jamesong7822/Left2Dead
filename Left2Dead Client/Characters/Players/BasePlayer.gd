extends "res://Characters/BaseCharacter.gd"

export (PackedScene) var Weapon

var weapon

func _ready():
	pass
	if get_network_master() != get_tree().get_network_unique_id():
		$Camera2D.queue_free()
		
	# attach the weapon
	weapon = Weapon.instance()
	add_child(weapon)
	
func _physics_process(delta):
	if currentEffect == EFFECT.NORMAL:
		handleMovement()
		handleShooting()
	
remotesync func respawn():
	var tween = Tween.new()
	tween.connect("tween_all_completed", self, "_onRespawnTweenComplete")
	add_child(tween)
	tween.interpolate_property(self, "currentHealth", 0, charHealth, 3)
	tween.interpolate_method($Healthbar, "updateHealth", 0, charHealth, 3)
	tween.start()

func _onRespawnTweenComplete():
	currentGameState = GAME_STATE.ALIVE
	
	
func handleShooting() -> void:
	pass
	if not is_network_master():
		return
	if currentGameState == GAME_STATE.DEAD:
		return
	if Input.is_action_pressed("shoot"):
		weapon.fire($FireFrom.global_position, get_global_mouse_position())
		# tell other connected clients that you should be firing
		weapon.rpc_id(-1, "syncFire", $FireFrom.global_position, get_global_mouse_position())
			

func handleMovement() -> void:
	pass
	if not is_network_master():
		return
	if currentGameState == GAME_STATE.DEAD:
		return
	moveDir = Vector2.ZERO
	if Input.is_action_pressed("up"):
		moveDir.y -= 1
	if Input.is_action_pressed("down"):
		moveDir.y += 1
	if Input.is_action_pressed("left"):
		moveDir.x -= 1
	if Input.is_action_pressed("right"):
		moveDir.x += 1
	# normalized the direction
	moveDir = moveDir.normalized()
	# rotate to face mouse
	look_at(get_global_mouse_position())
