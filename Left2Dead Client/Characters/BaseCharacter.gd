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
	if is_network_master():
		var charState = {}
		charState["T"] = Server.clientClock
		charState["P"] = get_global_position()
		charState["R"] = rotation
		Server.sendCharState(charState)
