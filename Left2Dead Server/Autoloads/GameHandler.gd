extends Node

var maxEnemies = 20
var spawnWithin = Vector2(140, 80)
var enemyCount = 0

onready var server = get_parent()

var t
var id = 0
var wepTimer

func _ready():
	t = Timer.new()
	add_child(t)
	t.autostart = false
	t.one_shot = false
	t.wait_time = 10
	t.connect("timeout", self, "_onTimerTimeout")
	_initWepTimer()
	
func _initWepTimer():
	wepTimer = Timer.new()
	add_child(wepTimer)
	wepTimer.autostart = false
	wepTimer.one_shot = false
	wepTimer.wait_time = 5
	wepTimer.connect("timeout", self, "_onWepTimerTimeout")
	
func start() ->void:
	if t.is_stopped():
		print_debug("Enemy Timer Started!")
		t.start()
		print_debug("Weapon Timer Started!")
		wepTimer.start()
		
func stop() -> void:
	print_debug("Stopping Game Handler")
	t.stop()
	wepTimer.stop()
	enemyCount = 0
	t.wait_time = 10
	wepTimer.wait_time = 5
	id = 0
		
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
			nodeOwner = server.players.keys()[0]
		print_debug("Spawn Enemy at: %s Target: %s Owner: %s ID: %s" %[enemyPos, target, nodeOwner, id])
		server.rpc("spawnEnemy", enemyPos, target, nodeOwner, id)
	
		enemyCount += 1
		id += 1
		
func _generateWepCoords():
	var randomX = (randf()*2-1) * spawnWithin.x/2 * 32
	var randomY = (randf()*2-1) * spawnWithin.y/2 * 32
	return Vector2(randomX, randomY)
	
func _onWepTimerTimeout():
	var wepPos = _generateWepCoords()
	# decide weapon to spawn
	var wepID = randi() % 2
	print_debug("Spawn weapon id: %s at %s" %[wepID, wepPos])
	server.rpc("spawnWeapon", wepID, wepPos)
