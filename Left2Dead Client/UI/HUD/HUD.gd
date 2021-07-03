extends CanvasLayer


func _ready():
	pass
	call_deferred("initWeaponHUD")

func initWeaponHUD():
	# update HUD clipsize
	var clipSize = get_parent().get_node("weapon").clipSize
	var ammo = get_parent().get_node("weapon").currentAmmo
	var weaponName = get_parent().get_node("weapon").weaponName
	$WeaponHUD._setClipSize(clipSize)
	$WeaponHUD._onUpdateWeaponHUD(clipSize, ammo)
	$WeaponHUD._setWeaponName(weaponName)
	# connect signal
	get_parent().get_node("weapon").connect("update_weapon_hud", $WeaponHUD, "_onUpdateWeaponHUD")
