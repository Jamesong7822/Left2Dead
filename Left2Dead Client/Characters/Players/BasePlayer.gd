extends "res://Characters/BaseCharacter.gd"


func _ready():
	pass
	if get_network_master() != get_tree().get_network_unique_id():
		$Camera2D.queue_free()
	
func moveTo(newPos):
	position = newPos

func rotateTo(newRotation):
	rotation = newRotation
	
func _physics_process(delta):
	handleMovement()
	
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
