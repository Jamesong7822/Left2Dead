extends Node

var maxEnemies = 10
var spawnWithin = Vector2(140, 80)
var enemyCount = 0

onready var server = get_parent()

var t

func _ready():
	t = Timer.new()
	add_child(t)
	t.autostart = false
	t.one_shot = false
	t.wait_time = 10
	t.connect("timeout", self, "_onTimerTimeout")
	
func startTimer() -> void:
	if t.is_stopped():
		print_debug("Enemy Timer Started!")
		t.start()
		
func generateRandomCoords() -> Vector2:
	var enemyPos = Vector2()
	# get the average of player pos
	var pos = Vector2()
	for playerID in server.playerStates.keys():
		pos += server.playerStates[playerID]["P"]
	var avgPos = pos / server.players.size()
	var randomX = (randf()*2-1) * 500
	var randomY = (randf()*2-1) * 500
	enemyPos = Vector2(randomX, randomY) + avgPos
	return enemyPos
	
func _onTimerTimeout():
	# do spawn of enemy
	if enemyCount > maxEnemies:
		return
	pass
	# random enemy pos
	var enemyPos = generateRandomCoords()
	if server.players.size() != 0:
		var target = server.players.keys()[randi() % server.players.size()]
		print_debug("Spawn Enemy at: %s with target: %s" %[enemyPos, target])
		server.rpc("spawnEnemy", enemyPos, target)
	
		enemyCount += 1
	
