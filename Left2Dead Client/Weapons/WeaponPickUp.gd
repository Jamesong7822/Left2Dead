extends Node2D

enum TYPE {PISTOL, MACHINE_GUN, SHOTGUN}

var BASE = "res://Weapons/BaseWeapon.tscn"
var MG = "res://Weapons/MachineGun.tscn"

export var type = TYPE.PISTOL

func _ready():
	pass
	$CharacterLabel._setYOffset(15)
	_updateLabel()
	
	
func _setType(newType):
	type = newType
	_updateLabel()
	
func _updateLabel():
	$CharacterLabel.setText(TYPE.keys()[type])
	
remotesync func _onPickup() -> void:
	call_deferred("queue_free")


func _on_Area2D_body_entered(body):
	pass # Replace with function body.
	if body.is_in_group("Players") and body.is_network_master():
		var wepInstance
		match type:
			TYPE.PISTOL:
				wepInstance = BASE
			TYPE.MACHINE_GUN:
				wepInstance = MG
		body.rpc_id(-1, "switchWeaponTo", wepInstance)
		rpc_id(-1, "_onPickup")
