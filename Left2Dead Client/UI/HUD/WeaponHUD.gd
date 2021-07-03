extends Control

var clipSize = 0

func _ready():
	pass
	
func _onUpdateWeaponHUD(clipSize, ammoLeft):
	pass
	_setClipLeft(clipSize)
	_setAmmoLeft(ammoLeft)

func _setClipSize(newClipSize:int) -> void:
	clipSize = newClipSize

func _setWeaponName(newWeaponName:String) -> void:
	$MarginContainer/HBoxContainer/WeaponName.text = newWeaponName

func _getWeaponName() -> String:
	return $MarginContainer/HBoxContainer/WeaponName.text
	
func _setClipLeft(newClip:int) -> void:
	var endWith = " / " + str(clipSize)
	$MarginContainer/HBoxContainer/Clip.text = str(newClip) + endWith
	
func _setAmmoLeft(ammoLeft:int) -> void:
	$MarginContainer/HBoxContainer/Ammo.text = str(ammoLeft)

