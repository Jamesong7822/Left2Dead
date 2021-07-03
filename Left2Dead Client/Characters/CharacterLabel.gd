extends Node2D

export var yOffset = -60


func _ready():
	pass
	init()
	
func _process(delta) -> void:
	global_rotation = 0
	
func init() -> void:
	# clear any testing words from the editor
	clearText()

func _setYOffset(newYOffset) -> void:
	yOffset = newYOffset
	
func centralizeText() -> void:
	# function centralizes the words
	var rect = $Label.rect_size
	$Label.rect_position.x = -rect.x/2
	$Label.rect_position.y = yOffset
	
func setText(newText) -> void:
	$Label.text = newText
	#yield(get_tree(), "idle_frame")
	# recentralize
	centralizeText()
	

func clearText() -> void:
	$Label.text = ""
