extends Node

var network = NetworkedMultiplayerENet.new()
#var ip = "127.0.0.1"
#var ip = "34.133.117.68" 
var ip = "103.102.46.178"
var port = 1909

var players = {}
var players_ready

var latency = 0
var latencyArray = []
var clientClock = 0
var deltaLatency = 0
var decimalCollector :=0.0

signal player_registered
signal player_unregistered
signal players_updated

func _ready():
	#connectToServer()
	network.connect("connection_failed", self, "_onConnectionFailed")
	network.connect("connection_succeeded", self, "_onConnectionSucceeded")
	get_tree().connect("server_disconnected", self, "_onServerDisconnected")

func _physics_process(delta) -> void:
	clientClock += int(delta*1000) + deltaLatency
	deltaLatency = 0
	decimalCollector += (delta*1000) - int(delta*1000)
	if decimalCollector >= 1.00:
		clientClock += 1
		decimalCollector -= 1.00

func connectToServer() -> void:
	if not get_tree().network_peer:
		network.create_client(ip, port)
		get_tree().set_network_peer(network)

func disconnectFromServer() -> void:
	# function for client to disconnect from server 
	if get_tree().network_peer:
		network.close_connection()
		get_tree().set_network_peer(null)
		players.clear()
	
func sendCharState(charState) -> void:
	rpc_unreliable_id(1, "getCharState", charState)
	
remote func getWorldState(worldState) -> void:
	get_tree().get_nodes_in_group("Map")[0].updateWorldState(worldState)
	
remote func register_player(id, new_player_data) -> void:
	print_debug("Registering player: %s" %id)
	players[id] = new_player_data
	emit_signal("player_registered")
	
	
remote func unregister_player(id) -> void:
	print_debug("Unregistering player: %s" %id)
	players.erase(id)
	emit_signal("player_unregistered")
	# TODO: if game is ongoing,shud remove player gracefully!
	var map = get_tree().get_nodes_in_group("Map")[0]
	map.despawnPlayer(id)

func updateServerEnemyCounter() -> void:
	if get_tree().network_peer:
		rpc_id(1, "updateEnemyCounter")

func setPlayerReady():
	# function informs server that client is ready
	rpc_id(1, "setPlayerReady")
	
func setPlayerNotReady():
	# function informs server that client is not ready
	rpc_id(1, "setPlayerNotReady")
	
remote func updatePlayersDict(newPlayersDict):
	if get_tree().get_rpc_sender_id() != 1:
		return
	players = newPlayersDict
	emit_signal("players_updated")
	
remote func startGame(mapSeed):
	if get_tree().get_rpc_sender_id() != 1:
		return
	# TODO: server will send mapseed over!
	var map = load("res://Maps/BaseMap.tscn").instance()
	get_tree().get_root().add_child(map)
	print_debug("Start Game!")
	map.initMap(mapSeed)
	for player in Server.players:
		map.spawnPlayer(player, Vector2(0,0))
	# remove lobby
	get_tree().get_root().get_node("Lobby").queue_free()
		
remote func spawnEnemy(coords:Vector2, target:int, nodeOwner, id:int):
	if get_tree().get_rpc_sender_id() != 1:
		return
	var map = get_tree().get_nodes_in_group("Map")[0]
	map.spawnEnemy(coords, target, nodeOwner, id)
	
func _onServerDisconnected() -> void:
	players.clear()
	print_debug("Server Disconnected")
	get_tree().set_network_peer(null)
	get_tree().get_nodes_in_group("Map")[0].queue_free()
	get_tree().change_scene("res://UI/Menu.tscn")
	
func _onConnectionFailed() -> void:
	print_debug("Failed to connect!")
	get_tree().set_network_peer(null)
	connectToServer()
	
func _onConnectionSucceeded() -> void:
	print_debug("Successfully Connected!")
	rpc_id(1, "register_player", "test")
	rpc_id(1, "getServerTime", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "calcLatency")
	add_child(timer)
	
remote func returnServerTime(serverTime, clientTime):
	latency = (OS.get_system_time_msecs() - clientTime)/2
	clientClock = serverTime + latency

func calcLatency():
	if get_tree().network_peer:
		rpc_id(1, "calcLatency", OS.get_system_time_msecs())
	
remote func returnLatency(clientTime):
	latencyArray.append((OS.get_system_time_msecs() - clientTime)/2)
	if latencyArray.size() > 9:
		var totalLatency = 0
		latencyArray.sort()
		var midPoint = latencyArray[4]
		for i in range(latencyArray.size()-1, -1, -1):
			if latencyArray[i] > (2*midPoint) and latencyArray[i] > 20:
				latencyArray.remove(i)
			else:
				totalLatency += latencyArray[i]
		deltaLatency = (totalLatency / latencyArray.size()) - latency
		latency = totalLatency / latencyArray.size()
		latencyArray.clear()
