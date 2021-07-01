extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

var players = {}
var playerStates = {}

func _ready() -> void:
	startServer()
	
func startServer() -> void:
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print_debug("Server Started!")
	
	network.connect("peer_connected", self, "_onPeerConnected")
	network.connect("peer_disconnected", self, "_onPeerDisconnected")
	
remote func getCharState(charState):
	var player_id = get_tree().get_rpc_sender_id()
	if playerStates.has(player_id):
		if playerStates[player_id]["T"] < charState["T"]:
			playerStates[player_id] = charState
	else:
		playerStates[player_id] = charState
		
func sendWorldState(worldState) -> void:
	rpc_unreliable("getWorldState", worldState)
	
remote func register_player(new_player_name) -> void:
	var caller_id = get_tree().get_rpc_sender_id()
	# add to players dict
	var playerDict = {}
	playerDict["name"] = new_player_name
	playerDict["ready"] = false
	players[caller_id] = playerDict
	# add previously connected players to this new player
	for player_id in players:
		if player_id != caller_id:
			rpc_id(caller_id, "register_player", player_id, players[player_id])
	# tell other connected players
	rpc("register_player", caller_id, players[caller_id])
	print_debug("Client: %s registered as %s" %[caller_id, new_player_name])
	
puppetsync func unregister_player(id) -> void:
	players.erase(id)
	playerStates.erase(id)
	print_debug("Client %s unregistered" %id)
	
remote func updateEnemyCounter() -> void:
	$GameHandler.enemyCount -= 1
	
func checkIfAllPlayersReady():
	var numReady = 0
	for player in players:
		if players[player]["ready"]:
			numReady += 1
	print_debug("Players Ready: %s/%s" %[numReady, players.size()])
	if numReady == players.size():
		return true
	return false
	
remote func setPlayerReady():
	# function is an rpc call from client to tell server that they are ready
	var clientID = get_tree().get_rpc_sender_id()
	print_debug("Client: %s is ready!" %[clientID])
	# update server players dict copy
	players[clientID]["ready"] = true
	# broadcast
	rpc("updatePlayersDict", players)
	# check if all players ready
	if checkIfAllPlayersReady():
		var mapSeed = randi()
		rpc("startGame", mapSeed)
		print_debug("Map Seed: %s" %mapSeed)
		# start the game handler
		$GameHandler.startTimer()
	
remote func setPlayerNotReady():
	# function is an rpc call from client to tell server that they are not ready
	var clientID = get_tree().get_rpc_sender_id()
	print_debug("Client: %s is not ready!" %[clientID])
	# update server players dict copy
	players[clientID]["ready"] = false
	# broadcast
	rpc("updatePlayersDict", players)
	
	
remote func getServerTime(clientTime):
	var clientID = get_tree().get_rpc_sender_id()
	rpc_id(clientID, "returnServerTime", OS.get_system_time_msecs(), clientTime)
	
remote func calcLatency(clientTime):
	var clientID = get_tree().get_rpc_sender_id()
	rpc_id(clientID, "returnLatency", clientTime)
	
func _onPeerConnected(player_id):
	print_debug("User %s connected!" %player_id)
	
func _onPeerDisconnected(player_id):
	print_debug("User %s disconnected!" %player_id)
	rpc("unregister_player", player_id)
	
