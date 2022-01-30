extends RigidBody2D

export var min_speed = 34    # Minimum speed range.
export var max_speed = 68    # Maximum speed range.




func _ready():
	var MobSpawn = get_parent().get_node("MobPath/MobSpawnLocation")
	var timer = get_parent().get_node("Timers/MobTimer")

	MobSpawn.offset = randi()
	var mob_types = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]
	$AnimatedSprite.z_index = 50

	# randomize scale
	var scale_min = .22 ; var scale_max = .38
	var scale_mid = (scale_min + scale_max) / 2
	var scale = rand_range(scale_min, scale_max)
	$AnimatedSprite.scale = (Vector2(scale, scale))
	$CollisionShape2D.scale = (Vector2(scale, scale))

	# Randomize color a bit
	var R = rand_range(.72, .90)
	var G = rand_range(.62, .99)
	var B = rand_range(.32, .44)
	$AnimatedSprite.self_modulate = Color(R,G,B)

	# Set the mob's direction perpendicular to the path direction.
	var direction = MobSpawn.rotation + PI / 2

	# Set the mob's position to a random location.
	position = MobSpawn.position

	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	rotation = direction - PI

	# Set the velocity (speed & direction).
	var speed_min = min_speed * (1 + (1 - timer.wait_time))
	speed_min += (speed_min / 4)
	var speed_max = max_speed * (1 + (1 - timer.wait_time))
	speed_max += (speed_max / 8)
#	print("min: "+ ("%.2f" % speed_min) +"    max: "+ ("%.2f" % speed_max))
	linear_velocity = Vector2(rand_range(speed_min, speed_max), 0)
	linear_velocity = linear_velocity.rotated(direction)

	var pitch = 1.2 - scale if scale >= scale_mid else 1.2 + scale
	$MobSound.pitch_scale += pitch
	$MobSound.play()




#func _process(_delta):
#	if position.distance_to(get_parent().get_node("player").position) > 150:
#		$MobSound.stream_paused = true
#	else:
#		$MobSound.stream_paused = false







func _on_VisibilityNotifier2D_screen_exited():
	queue_free()




func time_scale(effect):
	var scale = 2.0 if effect == "normal" else .5
	for instance in get_tree().get_nodes_in_group("mobs"):
		instance.linear_velocity *= scale
