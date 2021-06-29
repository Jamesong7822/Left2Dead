tool
extends Node2D

export (int) var length
export (int) var width

export (bool) var updateMap setget setupMap

func _ready():
	pass
	
remote func receiveMapSeed(mapSeed):
	if get_tree().get_rpc_sender_id() != 1:
		return
	pass
	
func setupMap(state):
	if state:
		var grass_no_nav_id = $Navigation2D/Ground.tile_set.find_tile_by_name("Grass no nav")
		var grass_id = $Navigation2D/Ground.tile_set.find_tile_by_name("Grass")
		$Navigation2D/Ground.clear()
		for x in range(-length/2, length/2):
			for y in range(-width/2, width/2):
				$Navigation2D/Ground.set_cell(x,y,grass_id)
		for x in range(-length/2, length/2):
			for y in range(-width/2, width/2):
				if $Navigation2D/Others.get_cell(x,y) != TileMap.INVALID_CELL:
					removeNavMesh(x, y, $Navigation2D/Others, $Navigation2D/Others.get_cell(x,y), grass_no_nav_id)
					#$Navigation2D/Ground.set_cell(x,y,grass_no_nav_id)

func removeNavMesh(x, y, tileMap, tileID, replaceWithTileID):
	var regionRect = tileMap.tile_set.tile_get_region(tileID)
	$Navigation2D/Ground.set_cell(x,y, replaceWithTileID)
	for i in range(regionRect.size[0]/$Navigation2D/Ground.cell_size[0]):
		for j in range(regionRect.size[1]/$Navigation2D/Ground.cell_size[1]):
			$Navigation2D/Ground.set_cell(x+i, y+j, replaceWithTileID)
