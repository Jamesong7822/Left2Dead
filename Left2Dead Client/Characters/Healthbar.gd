extends Node2D

export (Color) var healthyColor = Color.green
export (Color) var damagedColor = Color.yellow
export (Color) var criticalColor = Color.red

func _ready():
	pass
	init()
	centralize()
	
func _process(delta) -> void:
	global_rotation = 0
	
func init() -> void:
	# get the characters health
	call_deferred("updateHealth", get_parent().currentHealth)
	
func centralize() -> void:
	var rect = $TextureProgress.rect_size
	$TextureProgress.rect_position.x = -rect.x / 2
	$TextureProgress.rect_position.y = -45

func setMaxHealth(newMaxHealth) -> void:
	$TextureProgress.max_value = newMaxHealth
	
func updateHealth(newHealth) -> void:
	$TextureProgress.value = newHealth
	$TextureProgress.tint_progress = _assignColor()
	
func _assignColor() -> Color:
	if $TextureProgress.value < $TextureProgress.max_value * 0.4:
		return criticalColor
	elif $TextureProgress.value < $TextureProgress.max_value * 0.8:
		return damagedColor
	else:
		return healthyColor
