extends RigidBody2D


export var bonus_type = -1
var anim_scale  = true
var anim_rotate = true

var clock_anim_dir = 1


#var bonuses = [
#	["point",  80],
#	["clock",  95],
#	["bomb",  100]
#]
var bonuses = [
	["point",  94],
	["clock",  100],
]



func _ready():
	var bonus_spawn_offset = 60
	var val = randi() % 100

	for index in bonuses.size():
		if val <= bonuses[index][1]:
			bonus_type = index ; break

	var x = get_viewport().size.x
	var y = get_viewport().size.y

	var pos_x = rand_range(bonus_spawn_offset, x - bonus_spawn_offset)
	var pos_y = rand_range(bonus_spawn_offset, y - bonus_spawn_offset)
	set_position(Vector2(pos_x, pos_y))

	print("BONUS SPAWNED:  " + bonuses[bonus_type][0])    ## Wyjebać to

	match bonuses[bonus_type][0]:
		"point":
			point_bonus_anim("all")
			$Sprite.animation = "point"
		"clock":
			clock_bonus_anim(clock_anim_dir)
			$Sprite.animation = "clock"




func point_bonus_anim(anim_type):
	var scale_def = 1

	if anim_type == "rotation" or "all":
		$anim_rotation.interpolate_property($Sprite, "rotation",
			$Sprite.rotation, deg2rad(randi() % 360), rand_range(.1, .4),
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$anim_rotation.start()

	if anim_type == "scale" or "all":
		var scale = rand_range(scale_def - .4, scale_def + .4)
		$anim_scale.interpolate_property($Sprite, "scale",
			$Sprite.scale, Vector2(scale, scale), rand_range(.8, 1.6),
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$anim_scale.start()




func clock_bonus_anim(dir):
	var scale_def = .85
	var target_scale

	if dir == 1:
		target_scale = scale_def * 1.25
		clock_anim_dir = -1
	else:
		target_scale = scale_def - (scale_def * .25)
		clock_anim_dir = 1

	$anim_scale.interpolate_property($Sprite, "scale",
		$Sprite.scale, Vector2(target_scale, target_scale), 1,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$anim_scale.start()




func _on_anim_scale_end():
	match bonuses[bonus_type][0]:
		"point":
			point_bonus_anim("scale")
		"clock":
			clock_bonus_anim(clock_anim_dir)


func _on_anim_rotation_end():
	point_bonus_anim("rotation")
