extends Control

const MENU = "res://UI/Menu.tscn"
const READY_FRONT = "[color=#2A9D8F]"
const READY_END = "[/color]"

onready var playerLabel = $MarginContainer/VBoxContainer/RichTextLabel

func _ready():
	pass
	Server.connect("player_registered", self, "updatePlayerLabel")
	Server.connect("player_unregistered", self, "updatePlayerLabel")
	Server.connect("players_updated", self, "updatePlayerLabel")
	clearLobby()
	updatePlayerLabel()
	

func clearLobby():
	playerLabel.bbcode_text = ""
	
func updatePlayerLabel():
	# get from single source of truth
	var currentPlayers = Server.players.keys()
	var start = "[center]\n"
	var end = "[/center]"
	var newLabel = start
	for p in currentPlayers:
		if Server.players[p]["ready"]:
			# if player is ready
			newLabel += READY_FRONT + str(p) + READY_END + "\n"
		else:
			# player not ready
			newLabel += str(p) + "\n"
	newLabel += end
	playerLabel.bbcode_text = newLabel
	


func _on_BackButton_pressed():
	pass # Replace with function body.
	get_tree().change_scene(MENU)
	# TODO: disconect from server!
	Server.disconnectFromServer()


func _on_ReadyButton_toggled(button_pressed):
	if button_pressed:
		pass
		# Tell server im ready!
		Server.setPlayerReady()
	else:
		# Tell server not ready!
		pass
		Server.setPlayerNotReady()
