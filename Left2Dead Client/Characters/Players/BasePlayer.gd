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
	
	
func moveTo(newPos):
	position = newPos

func rotateTo(newRotation):
	rotation = newRotation
	
func _physics_process(delta):
	handleMovement()
	handleShooting()
	
func handleShooting() -> void:
	pass
	if not is_network_master():
		return
	if Input.is_action_pressed("shoot"):
		weapon.fire($FireFrom.global_position, get_global_mouse_position())
		# tell other connected clients that you should be firing
		for player in get_tree().get_network_connected_peers():
			if player != 1:
				weapon.rpc_id(player, "fire", $FireFrom.global_position, get_global_mouse_position())
func handleMovement() -> void:
	pass
	if not is_network_master():
		return
	var moveDir := Vector2.ZERO
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
	# move towards the move dir
	move_and_slide(moveDir*charSpeed)
	# rotate to face mouse
	look_at(get_global_mouse_position())
