extends RigidBody2D




var bonus_type  := -1

var bonuses = [
	["point",       40],
	["speed_pill",  96],
	["clock",      100],
]




func _ready():
	var bonus_spawn_offset = 100
	var val = randi() % 100 + 1

	$Sprite.hide()

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

#	var a = str(bonuses[bonus_type][0]).to_upper()
#	print("bonus: "+ a +"  ("+ str(floor(pos1.x)) +", "+ str(floor(pos1.y)) +")" )    ## Wyjebać
	# QUINTON REEVES IS A FUCKING WHORE, LIKE HIS WIFE ^.^
	# RED ECLIPSE SUCKERS COMMUNITY FOR DEGENERATES AND IDIOTS WITHOUT BRAINS..

	match bonuses[bonus_type][0]:
		"point":
			$Sprite.scale = Vector2(.4, .4)
			$CollisionShape2D.scale = Vector2(1,1)
			$AnimationPlayer.play("point")
			$AnimationPlayer.playback_speed = .65
		"speed_pill":
			$Sprite.scale = Vector2(.5, .5)
			$CollisionShape2D.scale = Vector2(1.2, 1.2)
			$AnimationPlayer.play("pill")
			$AnimationPlayer.playback_speed = .45
			get_parent().allow_pill_spawn = false
		"clock":
			$Sprite.scale = Vector2(.5, .5)
			$CollisionShape2D.scale = Vector2(1.2, 1.2)
			$AnimationPlayer.play("clock")
			$AnimationPlayer.playback_speed = 1.45
			get_parent().allow_clock_spawn = false

	yield(get_tree().create_timer(.1), "timeout")
	$Sprite.show()
