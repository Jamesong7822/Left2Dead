extends "res://Characters/BaseCharacter.gd"

export (float) var detectRadius = 10

var target
var path = []

func _ready():
	pass
	$DetectArea/CollisionShape2D.shape.radius = detectRadius
	
func _physics_process(delta):
	if target:
		generatePath()
		navigateToTarget()
		
func generatePath() -> void:
	if len(get_tree().get_nodes_in_group("Map")) != 0:
		var navNode = get_tree().get_nodes_in_group("Map")[0].get_node("Navigation2D")
		path = navNode.get_simple_path(global_position, target.global_position, true)

func navigateToTarget() -> void:
	if path.size() > 0:
		var moveDir = global_position.direction_to(path[1])
		move_and_slide(moveDir*charSpeed)
		
		if global_position == path[0]:
			path.remove(0)

func _on_DetectArea_body_entered(body):
	if body.is_in_group("Players"):
		print ("Detect Player!")
		target = body
