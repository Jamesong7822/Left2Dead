extends Node

var network = NetworkedMultiplayerENet.new()
#var ip = "127.0.0.1"
var ip = "34.70.83.236" 
var port = 1909

var players = {}

func _ready():
	connectToServer()
	network.connect("connection_failed", self, "_onConnectionFailed")
	network.connect("connection_succeeded", self, "_onConnectionSucceeded")
	get_tree().connect("server_disconnected", self, "_onServerDisconnected")

func connectToServer() -> void:
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
func sendCharState(charState) -> void:
	rpc_unreliable_id(1, "getCharState", charState)
	
remote func getWorldState(worldState) -> void:
	get_tree().get_root().get_node("Demo").updateWorldState(worldState)
	
	
remote func register_player(id, new_player_data) -> void:
	print_debug("Registering player: %s" %id)
	players[id] = new_player_data
	var demo = get_tree().get_root().get_node("Demo")
	demo.spawnPlayer(id, Vector2(0,0))
	
	
remote func unregister_player(id) -> void:
	print_debug("Unregistering player: %s" %id)
	players.erase(id)
	var demo = get_tree().get_root().get_node("Demo")
	demo.despawnPlayer(id)
	
func _onServerDisconnected() -> void:
	players.clear()
	print_debug("Server Disconnected")
	connectToServer()
	
func _onConnectionFailed() -> void:
	print_debug("Failed to connect!")
	get_tree().set_network_peer(null)
	connectToServer()
	
func _onConnectionSucceeded() -> void:
	print_debug("Successfully Connected!")
	rpc_id(1, "register_player", "test")
