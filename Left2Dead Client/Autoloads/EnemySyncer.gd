extends Node

var enemyStates := {}

var timer
var nodeOwner

func _ready():
	pass
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.01
	timer.connect("timeout", self, "_onTimerTimeout")
	timer.start()
	
	
func _physics_process(delta):
	if enemyStates.size() > 0:
		if get_tree().get_network_unique_id() == nodeOwner:
			rpc_id(-1, "updateEnemyStates", enemyStates)
		else:
			useEnemyStates()

remote func updateEnemyStates(newEnemyState):
	enemyStates = newEnemyState
	
func useEnemyStates():
	for e in get_tree().get_nodes_in_group("Enemy"):
		if enemyStates.has(e.name):
			e.global_position = enemyStates[e.name]["P"]
			e.rotation = enemyStates[e.name]["R"]
	
func createEnemyStates():
	enemyStates = {}
	if len(get_tree().get_nodes_in_group("Enemy")) == 0:
		return
	nodeOwner = get_tree().get_nodes_in_group("Enemy")[0].nodeOwner
	if get_tree().get_network_unique_id() != nodeOwner:
		return
	for e in get_tree().get_nodes_in_group("Enemy"):
		var dict = {}
		dict["P"] = e.global_position
		dict["R"] = e.rotation
		enemyStates[e.name] = dict
		
func _onTimerTimeout():
	createEnemyStates()
	
