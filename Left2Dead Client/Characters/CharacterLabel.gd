extends Node2D


func _ready():
	pass
	init()
	
func _process(delta) -> void:
	global_rotation = 0
	
func init() -> void:
	# clear any testing words from the editor
	clearText()
	
func centralizeText() -> void:
	# function centralizes the words
	var rect = $Label.rect_size
	$Label.rect_position.x = -rect.x/2
	$Label.rect_position.y = -60
	
func setText(newText) -> void:
	$Label.text = newText
	# recentralize
	centralizeText()
	

func clearText() -> void:
	$Label.text = ""
