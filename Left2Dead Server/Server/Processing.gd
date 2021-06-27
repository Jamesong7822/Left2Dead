extends Node

var worldState

func _physics_process(delta) -> void:
	if not get_parent().playerStates.empty():
		worldState = get_parent().playerStates.duplicate(true)
		for player in worldState.keys():
			worldState[player].erase("T")
		worldState["T"] = OS.get_system_time_msecs()
		
		get_parent().sendWorldState(worldState)
