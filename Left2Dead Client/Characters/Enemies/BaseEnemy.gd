extends "res://Characters/BaseCharacter.gd"

export (float) var detectRadius = 10
export (int) var damage = 10
export (int) var knockback = 70


enum STATES {IDLE, SEEK, CHASE}
var currentState = STATES.SEEK

puppet var puppet_pos
puppet var puppet_rot

var nodeOwner
var target
var path = []

var lastCalc

func _ready():
	pass
	$DetectArea/CollisionShape2D.shape.radius = detectRadius
	call_deferred("generatePath")

func _physics_process(delta):
	checkValidTarget()
	updateDebugLabel()
	stateHandler()
#	if get_tree().get_network_unique_id() == nodeOwner:
#		for player in get_tree().get_network_connected_peers():
#			if player != 1 and player != nodeOwner:
#				rpc_id(player, "syncEnemy", global_position, moveDir)
	
#remote func syncEnemy(pos, dir):
#	var senderID = get_tree().get_rpc_sender_id()
#	if senderID != nodeOwner:
#		return
#	global_position = pos
#	moveDir = dir
		
		
func checkValidTarget():
	if not target:
		# check if players are still alive
		for player in get_tree().get_nodes_in_group("Players"):
			if player.currentGameState == GAME_STATE.ALIVE:
				target = player
				break
		return target
	if is_instance_valid(target) and target.currentGameState == GAME_STATE.DEAD:
		# choose next available target
		for player in get_tree().get_nodes_in_group("Players"):
			if player.currentGameState == GAME_STATE.ALIVE:
				target = player
				break
			else:
				target = null
		
func stateHandler() -> void:
	if not target:
		currentState = STATES.IDLE
	if currentEffect == EFFECT.NORMAL:
		match currentState:
			STATES.IDLE:
				pass
				currentSpeed = 0
				if target:
					currentState = STATES.SEEK
			STATES.SEEK:
				pass
				navigateToTarget()
				currentSpeed = charSpeed
				if calcDistanceFromTarget() < 300:
					currentState = STATES.CHASE
					# clear path
					path.resize(0)
			STATES.CHASE:
				pass
				chase()
				currentSpeed = charSpeed * 2
				if calcDistanceFromTarget() > 500:
					currentState = STATES.SEEK
				

		# rotate to look properly
		look_at(global_position + moveDir)
				
func chase():
	if not target:
		return
	moveDir = (target.global_position - global_position).normalized()
	
			
func calcDistanceFromTarget() -> float:
	if not target:
		return INF
	return global_position.distance_to(target.global_position)
	
func updateDebugLabel():
	$CharacterLabel.setText(STATES.keys()[currentState])
		
func generatePath() -> void:
	if not target:
		return
	if len(get_tree().get_nodes_in_group("Map")) != 0:
		var navNode = get_tree().get_nodes_in_group("Map")[0].get_node("Navigation2D")
		path = navNode.get_simple_path(global_position, target.global_position, true)

func navigateToTarget() -> void:
	if path.size() > 0:
		moveDir = global_position.direction_to(path[0])
		
		if global_position.distance_to(path[0]) < 5:
			path.remove(0)
			
	if path.size() == 0:
		generatePath()

func _on_DetectArea_body_entered(body):
	if body.is_in_group("Players"):
		target = body


func _on_RegenPathTimer_timeout():
	if target and currentState == STATES.SEEK:
		#generatePath()
		pass


func _on_AttackArea_body_entered(body):
	pass # Replace with function body.
	$AttackArea/CollisionShape2D.call_deferred("set_disabled", true)
	$AttackTimer.start()
	if not target:
		return
	if body.is_in_group("Players") and int(target.name) == get_tree().get_network_unique_id():
		body.rpc_id(-1, "takeDamage", damage, moveDir, knockback)


func _on_AttackTimer_timeout():
	pass # Replace with function body.
	$AttackArea/CollisionShape2D.call_deferred("set_disabled", false)
