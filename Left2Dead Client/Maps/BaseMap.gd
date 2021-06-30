extends Node2D

export (int) var length
export (int) var width

var lastWorldStateTime = 0
var worldStateBuffer = []

var terrainNoise
var obstacleNoise


func _ready():
	pass

	
func _physics_process(delta) -> void:
	interpolateWorldStates()
	
	
func spawnEnemy(enemyPos:Vector2, target) -> void:
	var e = Global.ENEMY.instance()
	e.target = get_tree().get_nodes_in_group("Map")[0].get_node(str(target))
	e.global_position = enemyPos
	add_child(e)
	
func initMap(mapSeed):
	terrainNoise = generateNoise(mapSeed)
	obstacleNoise = generateNoise(mapSeed)
	setupMap()
	
func generateNoise(mapSeed=0) -> OpenSimplexNoise:
	var noise = OpenSimplexNoise.new()

	# Configure
	noise.seed = mapSeed
	noise.octaves = 4
	noise.period = 250
	noise.persistence = 0.2
	noise.lacunarity = 2
	
	return noise
	
func selectGroundTile(x, y) -> int:
	# x,y are in map coords
	var world = $Navigation2D/Ground.map_to_world(Vector2(x, y))
	# get the noise
	var sample = terrainNoise.get_noise_2d(world.x, world.y)
	if sample < -0.5:
		return 2
	elif sample < -0.1:
		return 1
	else:
		return 0
		
func selectObstacleTile(x:int, y:int) -> int:
	# x,y are in map coords
	var world = $Navigation2D/Others.map_to_world(Vector2(x, y))
	# get the noise
	var sample = obstacleNoise.get_noise_2d(world.x, world.y)
	if sample > 0.5 and sample < 0.55:
		if randf() < 0.2:
			var random_num = randi() % 4
			return random_num

	return -1
	
func setupMap():

	var grass_no_nav_id = $Navigation2D/Ground.tile_set.find_tile_by_name("Grass no nav")
	var grass_id = $Navigation2D/Ground.tile_set.find_tile_by_name("Grass")
	$Navigation2D/Ground.clear()
	for x in range(-length/2, length/2):
		for y in range(-width/2, width/2):
			# fill in the terrain
			var id = selectGroundTile(x, y)
			$Navigation2D/Ground.set_cell(x,y,id)
			# fill in the obstacles
			id = selectObstacleTile(x,y)
			if id != -1:
				$Navigation2D/Others.set_cell(x,y,id)
	
	# loop through obstacles and remove navmesh!
	for x in range(-length/2, length/2):
		for y in range(-width/2, width/2):
			if $Navigation2D/Others.get_cell(x,y) != TileMap.INVALID_CELL:
				removeNavMesh(x, y, $Navigation2D/Others, $Navigation2D/Others.get_cell(x,y), grass_no_nav_id)
				$Navigation2D/Ground.set_cell(x,y,grass_no_nav_id)

func removeNavMesh(x, y, tileMap, tileID, replaceWithTileID):
	var regionRect = tileMap.tile_set.tile_get_region(tileID)
	$Navigation2D/Ground.set_cell(x,y, replaceWithTileID)
	for i in range(regionRect.size[0]/$Navigation2D/Ground.cell_size[0]):
		for j in range(regionRect.size[1]/$Navigation2D/Ground.cell_size[1]):
			$Navigation2D/Ground.set_cell(x+i, y+j, replaceWithTileID)

func spawnPlayer(id, spawn_pos) -> void:
	var player = Global.PLAYER.instance()
	player.position = spawn_pos
	player.name = str(id)
	player.set_network_master(id)
	add_child(player)

func despawnPlayer(id) -> void:
	print_debug("Despawning player %s" %id)
	get_node(str(id)).queue_free()
	
func updateWorldState(worldState) -> void:
	if worldState["T"] > lastWorldStateTime:
		lastWorldStateTime = worldState["T"]
		worldStateBuffer.append(worldState)

func interpolateWorldStates() -> void:
	var renderTime = Server.clientClock - 150
	# more than 2 buffer to interpolate 
	if worldStateBuffer.size() > 1:
		# remove the "too old" world states
		while worldStateBuffer.size() > 2 and renderTime > worldStateBuffer[2].T:
			worldStateBuffer.remove(0)
		if worldStateBuffer.size() > 2:
			# calaculate interpolation factor
			var interpFactor = float(renderTime - worldStateBuffer[1]["T"])/float(worldStateBuffer[2]["T"]-worldStateBuffer[0]["T"])
			for key in worldStateBuffer[2].keys():
				if str(key) == "T":
					# don't do anything for the world state time stamp
					continue
				if key == get_tree().get_network_unique_id():
					continue
				if not worldStateBuffer[1].has(key):
					# player does not have a prev world state reference
					continue
				if has_node(str(key)):
					var newPos = lerp(worldStateBuffer[1][key]["P"], worldStateBuffer[2][key]["P"], interpFactor)
					var newRot = lerp_angle(worldStateBuffer[1][key]["R"], worldStateBuffer[2][key]["R"], interpFactor)
					get_node(str(key)).moveTo(newPos)
					get_node(str(key)).rotateTo(newRot)
		elif renderTime > worldStateBuffer[1].T:
			var extrapFactor = float(renderTime-worldStateBuffer[0]["T"])/float(worldStateBuffer[1]["T"]-worldStateBuffer[0]["T"]) -1.00
			for key in worldStateBuffer[1].keys():
				if str(key) == "T":
					continue
				if key == get_tree().get_network_unique_id():
					continue
				if not worldStateBuffer[0].has(key):
					continue
				if has_node(str(key)):
					var posDelta = (worldStateBuffer[1][key]["P"] -worldStateBuffer[0][key]["P"])
					var newPos = worldStateBuffer[1][key]["P"] + posDelta*extrapFactor
					var rotDelta = (worldStateBuffer[1][key]["R"]-worldStateBuffer[0][key]["R"])
					var newRot = worldStateBuffer[1][key]["R"] + rotDelta*extrapFactor
					get_node(str(key)).moveTo(newPos)
					get_node(str(key)).rotateTo(newRot)
