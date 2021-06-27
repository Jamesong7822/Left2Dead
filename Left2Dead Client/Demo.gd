extends Node2D

var PLAYER = preload("res://Characters/Players/BasePlayer.tscn")

var lastWorldStateTime = 0
var worldStateBuffer = []

func _ready():
	pass
	
func spawnPlayer(id, spawn_pos) -> void:
	var player = PLAYER.instance()
	player.position = spawn_pos
	player.name = str(id)
	player.set_network_master(id)
	add_child(player)

func despawnPlayer(id) -> void:
	print_debug("Despawning player %s" %id)
	get_node(str(id)).queue_free()
	
func _physics_process(delta) -> void:
	interpolateWorldStates()
	
func updateWorldState(worldState) -> void:
	if worldState["T"] > lastWorldStateTime:
		lastWorldStateTime = worldState["T"]
		worldStateBuffer.append(worldState)

func interpolateWorldStates() -> void:
	var renderTime = OS.get_system_time_msecs() - 150
	# more than 2 buffer to interpolate 
	if worldStateBuffer.size() > 1:
		# remove the "too old" world states
		while worldStateBuffer.size() > 2 and renderTime > worldStateBuffer[1].T:
			worldStateBuffer.remove(0)
		# calaculate interpolation factor
		var interpFactor = float(renderTime - worldStateBuffer[0]["T"])/float(worldStateBuffer[1]["T"]-worldStateBuffer[0]["T"])
		for key in worldStateBuffer[1].keys():
			if str(key) == "T":
				# don't do anything for the world state time stamp
				continue
			if key == get_tree().get_network_unique_id():
				continue
			if not worldStateBuffer[0].has(key):
				# player does not have a prev world state reference
				continue
			if has_node(str(key)):
				var newPos = lerp(worldStateBuffer[0][key]["P"], worldStateBuffer[1][key]["P"], interpFactor)
				var newRot = lerp_angle(worldStateBuffer[0][key]["R"], worldStateBuffer[1][key]["R"], interpFactor)
				get_node(str(key)).moveTo(newPos)
				get_node(str(key)).rotateTo(newRot)
