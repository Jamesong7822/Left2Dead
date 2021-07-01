extends KinematicBody2D

enum TYPE {PLAYER, ENEMY}
enum GAME_STATE {ALIVE, DEAD}
enum EFFECT {NORMAL, KNOCKBACK, SLOWED, STUN}

export(TYPE) var charType
export var charName := ""
export var charDesc := ""
export var charSpeed :int
export var charHealth :int

var currentGameState = GAME_STATE.ALIVE
var currentEffect = EFFECT.NORMAL

var currentSpeed = charSpeed
var currentHealth = charHealth
var moveDir :=Vector2()

signal take_damage

func _ready() -> void:
	pass
	currentHealth = charHealth
	currentSpeed = charSpeed
	# connect signals
	connect("take_damage", $Healthbar, "updateHealth")
	$Healthbar.init()

func _physics_process(delta) -> void:
	defineCharState()
	effectHandler()
	gameStateHandler()
	
func moveTo(newPos):
	position = newPos

func rotateTo(newRotation):
	rotation = newRotation
	
func effectHandler() -> void:
	match currentEffect:
		EFFECT.NORMAL:
			pass
		EFFECT.KNOCKBACK:
			pass
			
	move_and_slide(moveDir*currentSpeed)
	
func gameStateHandler() -> void:
	match currentGameState:
		GAME_STATE.ALIVE:
			pass
			if currentHealth <= 0:
				die()
		GAME_STATE.DEAD:
			pass
			
func die() -> void:
	currentGameState = GAME_STATE.DEAD
	match charType:
		TYPE.PLAYER:
			pass
			# TODO: respawn!
			rpc_id(-1, "respawn")
		TYPE.ENEMY:
			# tell server to update enemy counter
			Server.updateServerEnemyCounter()
			rpc_id(-1, "syncedQueueFree")
			
remotesync func syncedQueueFree() -> void:
	queue_free()
	
remotesync func takeDamage(dmg: int, knockbackDir: Vector2, knockbackForce: int) -> void:
	# TODO: implement it server side to prevent cheating!
	# currently exposed to clients for quicker prototyping
	currentHealth -= dmg
	applyKnockback(knockbackDir, knockbackForce)
	emit_signal("take_damage", currentHealth)
	
func applyKnockback(knockbackDir:Vector2, knockbackForce:int) -> void:
	currentEffect = EFFECT.KNOCKBACK
	moveDir = knockbackDir
	currentSpeed = knockbackForce
	$EffectTimer.wait_time = 0.1
	$EffectTimer.start()

func _on_EffectTimer_timeout():
	pass # Replace with function body.
	currentEffect = EFFECT.NORMAL
	currentSpeed = charSpeed
		
func defineCharState() -> void:
	if is_network_master():
		var charState = {}
		charState["T"] = Server.clientClock
		charState["P"] = get_global_position()
		charState["R"] = rotation
		charState["H"] = currentHealth
		Server.sendCharState(charState)


