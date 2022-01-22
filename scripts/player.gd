extends Area2D

signal hit
signal bonus_collected

export var speed = 380


var screen_size
var target = Vector2()
var sound_player_move_allow




func _ready():
	hide()
	screen_size = get_viewport_rect().size




func start(pos):
	position = pos ; target = pos
	sound_player_move_allow = true
	$CollisionShape2D.disabled = false
	show()




func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target = event.position
		var rotation = position.angle_to_point(target)
		$AnimatedSprite.rotation = rotation
		$CollisionShape2D.rotation = rotation
		$Particles2D.rotation = rotation
		$Particles2D.emitting = true




func _process(delta):
	var velocity = Vector2()

	# Move towards the target and stop when close.
	if position.distance_to(target) > 10:
		velocity = target - position

	if velocity.length() > 0 and is_visible_in_tree():
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
		if sound_player_move_allow:
			$player_move.play()
			sound_player_move_allow = false
	else:
		$AnimatedSprite.stop()
		$Particles2D.emitting = false
		$player_move.stop()

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)








func _on_player_body_entered(body):
	match body.get_groups():
		["bonus"]:
			emit_signal("bonus_collected")
		["mobs"]:
			hide()
			emit_signal("hit")
			$CollisionShape2D.set_deferred("disabled", true)
			yield(get_tree().create_timer(1), "timeout")
			$Particles2D.restart()




func _on_player_move_finished():
	sound_player_move_allow = true
