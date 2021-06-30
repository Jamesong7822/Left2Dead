extends KinematicBody2D

enum TYPE {PLAYER, ENEMY}

export(TYPE) var charType
export var charName := ""
export var charDesc := ""
export var charSpeed :int
export var charHealth :int

var currentSpeed = charSpeed
var currentHealth = charHealth

signal take_damage

func _ready() -> void:
	pass

func _physics_process(delta) -> void:
	defineCharState()
	
remotesync func takeDamage(dmg) -> void:
	# TODO: implement it server side to prevent cheating!
	# currently exposed to clients for quicker prototyping
	currentHealth -= dmg
	emit_signal("take_damage")
		
func defineCharState() -> void:
	if is_network_master():
		var charState = {}
		charState["T"] = Server.clientClock
		charState["P"] = get_global_position()
		charState["R"] = rotation
		Server.sendCharState(charState)
