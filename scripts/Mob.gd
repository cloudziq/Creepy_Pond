extends RigidBody2D

export var min_speed = 50    # Minimum speed range.
export var max_speed = 85    # Maximum speed range.




func _ready():
	var mob_types = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]

	var scale = rand_range(.28, .54)
	$AnimatedSprite.set_scale(Vector2(scale, scale))
	$CollisionShape2D.set_scale(Vector2(scale, scale))




func _on_VisibilityNotifier2D_screen_exited():
	queue_free()




func time_scale(effect):
# warning-ignore:incompatible_ternary
	var scale = 2.0 if effect == "normal" else .5
	for instance in get_tree().get_nodes_in_group("mobs"):
		instance.linear_velocity *= scale
