extends Node

onready var server_connection := $ServerConnection

func _ready() -> void:
	yield(request_authentication(), "completed")
	yield(connect_to_server_async(), "completed")
	yield(join_world_async(), "completed")

func request_authentication() -> void:
	var email := "test@test.com"
	var password := "password"
	
	print_debug("Authenticating User %s" %email)
	var result :int = yield(server_connection.authenticate_async(email, password), "completed")
	
	if result == OK:
		print_debug("Authenticate User %s Successfully" %email)
	else:
		print_debug("Could not authenticate User %s" %email)

func connect_to_server_async() -> void:
	var result: int = yield(server_connection.connect_to_server_async(), "completed")
	if result == OK:
		print_debug("Connected to server!")
	elif result == ERR_CANT_CONNECT:
		print_debug("Could not connect!")

func join_world_async() -> void:
	var presences: Dictionary = yield(server_connection.join_world_async(), "completed")
	print_debug("Joined World")
	print_debug("Other connected players: %s" %presences.size())
