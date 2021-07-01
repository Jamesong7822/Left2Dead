extends Node

var maxEnemies = 30
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
	
func _getAlivePlayers():
	var alivePlayers = []
	for player in server.players.keys():
		if server.playerStates[player]["H"] > 0:
			alivePlayers.append(player)
	if len(alivePlayers) != 0:
		return alivePlayers
	else:
		return null
	
func _onTimerTimeout():
	# do spawn of enemy
	if enemyCount > maxEnemies:
		return
	t.wait_time -= 0.5
	if t.wait_time < 3:
		t.wait_time = 3
	# random enemy pos
	var enemyPos = generateRandomCoords()
	if server.players.size() != 0:
		var alivePlayers = _getAlivePlayers()
		print_debug("Alive Players: %s" %alivePlayers)
		var target = 0
		var nodeOwner = 0
		if alivePlayers:
			target = alivePlayers[randi() % len(alivePlayers)]
			nodeOwner = server.players[0]
		print_debug("Spawn Enemy at: %s with target: %s" %[enemyPos, target])
		server.rpc("spawnEnemy", enemyPos, target, nodeOwner)
	
		enemyCount += 1
	
