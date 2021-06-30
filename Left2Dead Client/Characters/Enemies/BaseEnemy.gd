extends "res://Characters/BaseCharacter.gd"

export (float) var detectRadius = 10

enum STATES {IDLE, SEEK, CHASE}
var currentState = STATES.SEEK

var target
var path = []
var moveDir := Vector2()

var lastCalc

func _ready():
	pass
	$DetectArea/CollisionShape2D.shape.radius = detectRadius
	call_deferred("generatePath")

func _physics_process(delta):
	updateDebugLabel()
	if target:
		stateHandler()
		
func stateHandler() -> void:
	match currentState:
		STATES.IDLE:
			pass
		STATES.SEEK:
			pass
			navigateToTarget()
			currentSpeed = charSpeed
			if calcDistanceFromTarget() < 200:
				currentState = STATES.CHASE
				# clear path
				path.resize(0)
		STATES.CHASE:
			pass
			chase()
			if calcDistanceFromTarget() > 400:
				currentState = STATES.SEEK
				
	move_and_slide(moveDir*currentSpeed)
	# rotate to look properly
	look_at(global_position + moveDir)
				
func chase():
	moveDir = (target.global_position - global_position).normalized()
	currentSpeed = charSpeed * 2
			
func calcDistanceFromTarget() -> float:
	return global_position.distance_to(target.global_position)
	
func updateDebugLabel():
	$CharacterLabel.setText(STATES.keys()[currentState])
		
func generatePath() -> void:
	print ("Generating Path")
	if len(get_tree().get_nodes_in_group("Map")) != 0:
		var navNode = get_tree().get_nodes_in_group("Map")[0].get_node("Navigation2D")
		path = navNode.get_simple_path(global_position, target.global_position, true)

func navigateToTarget() -> void:
	if path.size() > 0:
		moveDir = global_position.direction_to(path[0])
		
		if global_position.distance_to(path[0]) < 5:
			print ("removing")
			path.remove(0)
			
	if path.size() == 0:
		generatePath()

func _on_DetectArea_body_entered(body):
	if body.is_in_group("Players"):
		print ("Detect Player!")
		target = body


func _on_RegenPathTimer_timeout():
	if target:
#		generatePath()
		pass
