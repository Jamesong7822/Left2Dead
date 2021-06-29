extends Control

const LOBBY = "res://UI/Lobby.tscn"

func _ready():
	pass


func _on_PlayButton_pressed():
	pass # Replace with function body.
	# move to lobby page & connect to server!
	get_tree().change_scene(LOBBY)
	Server.connectToServer()
	


func _on_SettingsButton_pressed():
	pass # Replace with function body.
