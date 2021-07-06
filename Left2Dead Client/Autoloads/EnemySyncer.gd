extends Node

var enemyStates := {}
var enemyStatesBuffer = []

const UPDATE_RATE = 30 #FPS

var timer
var nodeOwner

func _ready():
	pass
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0/UPDATE_RATE
	timer.connect("timeout", self, "_onTimerTimeout")
	timer.start()
	
	
func _physics_process(delta):
#	applyEnemyStates()
	if get_tree().network_peer:
		if nodeOwner != get_tree().get_network_unique_id():
			useEnemyStates()

remote func updateEnemyStates(newEnemyState):
	enemyStates = newEnemyState
	if len(enemyStatesBuffer) == 0:
		enemyStatesBuffer.append(newEnemyState)
	else:
		# check for timestamp
		var timestamp = newEnemyState["T"]
		if timestamp > enemyStatesBuffer[-1]["T"]:
			enemyStatesBuffer.append(newEnemyState)
			
		# remove extra enemystates
#		while len(enemyStatesBuffer) > 2:
#			enemyStatesBuffer.remove(0)
	
func applyEnemyStates():
	if enemyStatesBuffer.size() > 2:
		# can do interpolation
		var interpA = enemyStatesBuffer[-2]
		var interpB = enemyStatesBuffer[-1]
		var renderTime = Server.clientClock - 150
		while enemyStatesBuffer.size() > 2 and renderTime > enemyStatesBuffer[2].T:
			enemyStatesBuffer.remove(0)
		
		if enemyStatesBuffer.size() > 2:
			var interpFactor = float(renderTime - enemyStatesBuffer[1]["T"])/float(enemyStatesBuffer[2]["T"]-enemyStatesBuffer[0]["T"])
			for e in get_tree().get_nodes_in_group("Enemy"):
				if interpA.has(e.name) and interpB.has(e.name):
					e.global_position = lerp(interpA[e.name]["P"], interpB[e.name]["P"], interpFactor)
					e.rotation = lerp_angle(interpA[e.name]["R"], interpB[e.name]["R"], interpFactor)
	
func useEnemyStates():
	for e in get_tree().get_nodes_in_group("Enemy"):
		if enemyStates.has(e.name):
#			e.global_position = enemyStates[e.name]["P"]
#			e.rotation = enemyStates[e.name]["R"]
			e.global_position = lerp(e.global_position, enemyStates[e.name]["P"], 0.5)
			e.rotation = lerp_angle(e.rotation, enemyStates[e.name]["R"], 0.5)
			

	
func createEnemyStates():
	enemyStates = {}
	# check if there are any enemies to record states for
	if len(get_tree().get_nodes_in_group("Enemy")) == 0:
		return
	nodeOwner = get_tree().get_nodes_in_group("Enemy")[0].nodeOwner
	if get_tree().get_network_unique_id() != nodeOwner:
		return
	# record down a timestamp
	enemyStates["T"] = Server.clientClock
	for e in get_tree().get_nodes_in_group("Enemy"):
		var dict = {}
		dict["P"] = e.global_position
		dict["R"] = e.rotation
		enemyStates[e.name] = dict
	# broadcast to all connected clients
	if get_tree().get_network_unique_id() == nodeOwner:
		rpc_unreliable_id(-1, "updateEnemyStates", enemyStates)
	
func _onTimerTimeout():
	createEnemyStates()
	
