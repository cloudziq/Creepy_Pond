extends RigidBody2D

export var min_speed = 34    # Minimum speed range.
export var max_speed = 68    # Maximum speed range.




func _ready():
	var MobSpawn = get_parent().get_node("MobPath/MobSpawnLocation")
	var timer = get_parent().get_node("Timers/MobTimer")

	MobSpawn.offset = randi()
	var mob_types = $Sprite/AnimationPlayer.get_animation_list()
#	$Sprite/AnimationPlayer.assigned_animation = mob_types[randi() % mob_types.size()]
	$Sprite/AnimationPlayer.play(mob_types[rand_range(1, mob_types.size())])
	z_index = 10

	# randomize scale
	var scale_min = .12 ; var scale_max = .18
	var scale_mid = (scale_min + scale_max) / 2
	var scale = rand_range(scale_min, scale_max)
	$Sprite.scale = (Vector2(scale, scale))
	$CollisionShape2D.scale = (Vector2(scale, scale))

	# Randomize color a bit
	var R = rand_range(.72, .90)
	var G = rand_range(.62, .99)
	var B = rand_range(.32, .44)
	$Sprite.self_modulate = Color(R,G,B)

	# Set the mob's direction perpendicular to the path direction.
	var direction = MobSpawn.rotation + PI / 2

	# Set the mob's position to a random location.
	position = MobSpawn.position

	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	rotation = direction - PI

	# Set the velocity (speed & direction).
	var speed_min = min_speed * (1 + (1 - timer.wait_time))
	speed_min += (speed_min * .1)
	var speed_max = max_speed * (1 + (1 - timer.wait_time))
	speed_max += (speed_max * .2)
#	print("min: "+ ("%.2f" % speed_min) +"    max: "+ ("%.2f" % speed_max))
	var speed = rand_range(speed_min, speed_max)
	linear_velocity = Vector2(speed, 0)
	print(speed)
	linear_velocity = linear_velocity.rotated(direction)

	$Sprite/AnimationPlayer.playback_speed = .4 + (speed / 100)

	var pitch = 1.2 - scale if scale >= scale_mid else 1.2 + scale
	$MobSound.pitch_scale += pitch
	$MobSound.play()




func _on_VisibilityNotifier2D_screen_exited():
	queue_free()




func time_scale(effect):
	var scale = 2.0 if effect == "normal" else .5
	for instance in get_tree().get_nodes_in_group("mobs"):
		instance.linear_velocity *= scale
		instance.get_node("clock_particles").emitting = true
		instance.get_node("Sprite/AnimationPlayer").playback_speed *= .5
