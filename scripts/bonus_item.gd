extends RigidBody2D




var bonus_type = -1
var anim_scale  = true
var anim_rotate = true

var anim_dir ; var anim_iter


var bonuses = [
	["point",       76],
	["speed_pill",  96],
	["clock",      100],
#	["point",       16],
#	["speed_pill",  26],
#	["clock",      100],
]




func _ready():
	var bonus_spawn_offset = 80
	var val = randi() % 100 + 1
	anim_dir = 1 ; anim_iter = 0

	for index in bonuses.size():
		if val <= bonuses[index][1]:
			if bonuses[index][0] == "speed_pill" and not get_parent().allow_pill_spawn:
				continue
			if bonuses[index][0] == "clock" and not get_parent().allow_clock_spawn:
				index = 0
			bonus_type = index ; break

	var screen_w = get_viewport_rect().size.x
	var screen_h = get_viewport_rect().size.y
	var pos1 = Vector2(-1, -1)
	var pos2 = get_parent().get_node("player").position

	while pos1.x == -1 or pos1.distance_to(pos2) <= screen_h / 3:
		pos1.x = rand_range(bonus_spawn_offset, screen_w - bonus_spawn_offset)
		pos1.y = rand_range(bonus_spawn_offset, screen_h - bonus_spawn_offset)
	position = pos1

	var a = str(bonuses[bonus_type][0]).to_upper()
	print("bonus: "+ a +"  ("+ str(floor(pos1.x)) +", "+ str(floor(pos1.y)) +")" )    ## Wyjebać

	match bonuses[bonus_type][0]:
		"point":
#			point_bonus_anim("all")
			$Sprite.scale = Vector2(.4, .4)
			$CollisionShape2D.scale = Vector2(1,1)
			$Sprite/AnimationPlayer.play("point")
		"speed_pill":
			pill_bonus_anim(1)
			$Sprite.scale = Vector2(.5, .5)
			$CollisionShape2D.scale = Vector2(1.2, 1.2)
			$Sprite/AnimationPlayer.play("pill")
			get_parent().allow_pill_spawn = false
		"clock":
			clock_bonus_anim(1, 0)
			$Sprite.scale = Vector2(.5, .5)
			$CollisionShape2D.scale = Vector2(1.2, 1.2)
			$Sprite/AnimationPlayer.play("clock")
			get_parent().allow_clock_spawn = false




#func point_bonus_anim(anim_type):
#	var scale_def = .5
#
#	if anim_type == "rotation" or "all":
#		$anim_rotation.interpolate_property($Sprite, "rotation",
#			$Sprite.rotation, deg2rad(randi() % 360), rand_range(.1, .4),
#			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		$anim_rotation.start()
#
#	if anim_type == "scale" or "all":
#		var scale = rand_range(scale_def * .6, scale_def * 1.1)
#		$anim_scale.interpolate_property($Sprite, "scale",
#			$Sprite.scale, Vector2(scale, scale), rand_range(.8, 1.6),
#			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		$anim_scale.start()




func pill_bonus_anim(dir):
	var rot ; var time ; var delay

	if dir == 1:
		rot = 270
		time = .6
		delay = .2
		anim_dir = -1
	else:
		rot = 0
		time = .6
		delay = .6
		anim_dir = 1

	$anim_rotation.interpolate_property($Sprite, "rotation_degrees",
		$Sprite.rotation_degrees, rot, time,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
	$anim_rotation.start()




func clock_bonus_anim(dir, iter):
	var rot ; var delay
	anim_iter += 1

	if iter < 7:
		delay = .01
		if dir == 1:
			rot = 16
			anim_dir = -1
		else:
			rot = -16
			anim_dir = 1
	elif iter == 7:
		delay = .005
		rot = 0
	else:
		rot = 0
		delay = 1
		anim_dir = 1
		anim_iter = 0

	$anim_rotation.interpolate_property($Sprite, "rotation_degrees",
		$Sprite.rotation_degrees, rot, .06,
		Tween.TRANS_LINEAR, 0, delay)
	$anim_rotation.start()








#func _on_anim_scale_end():
#	match bonuses[bonus_type][0]:
#		"point":
#			point_bonus_anim("scale")


func _on_anim_rotation_end():
	match bonuses[bonus_type][0]:
#		"point":
#			point_bonus_anim("rotation")
		"speed_pill":
			pill_bonus_anim(anim_dir)
		"clock":
			clock_bonus_anim(anim_dir, anim_iter)
