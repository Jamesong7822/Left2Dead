extends KinematicBody2D

enum TYPE {PLAYER, ENEMY}

export(TYPE) var charType
export var charName := ""
export var charDesc := ""
export var charSpeed :int

puppet var puppet_pos := Vector2()


func _physics_process(delta) -> void:
	defineCharState()
		
func defineCharState() -> void:
	if get_network_master() == get_tree().get_network_unique_id():
		var charState = {}
		charState["T"] = OS.get_system_time_msecs()
		charState["P"] = get_global_position()
		charState["R"] = rotation
		Server.sendCharState(charState)
