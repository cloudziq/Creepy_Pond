extends RigidBody2D

export var min_speed = 32    # Minimum speed range.
export var max_speed = 64    # Maximum speed range.




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
	var scale = rand_range(.22, .38)
	$AnimatedSprite.set_scale(Vector2(scale, scale))
	$CollisionShape2D.set_scale(Vector2(scale, scale))

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
	rotation = direction

	# Set the velocity (speed & direction).
	var speed_min = min_speed * (1 + (1 - timer.wait_time))
	var speed_max = max_speed * (1 + (1 - timer.wait_time))
#		print("min: "+ ("%.2f" % speed_min) +"    max: "+ ("%.2f" % speed_max))
	linear_velocity = Vector2(rand_range(speed_min, speed_max), 0)
	linear_velocity = linear_velocity.rotated(direction)

	var pitch = 1 - scale if scale >= scale_mid else 1 + scale
	$MobSound.pitch_scale += pitch
	$MobSound.play()




func _on_VisibilityNotifier2D_screen_exited():
	queue_free()




func time_scale(effect):
	var scale = 2.0 if effect == "normal" else .5
	for instance in get_tree().get_nodes_in_group("mobs"):
		instance.linear_velocity *= scale
