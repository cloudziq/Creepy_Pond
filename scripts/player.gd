extends Area2D


signal hit
signal bonus_collected

export var speed := 100.0

onready var screen_size = get_viewport_rect().size

var target = Vector2()




func _ready():
	hide()




func start(pos):
	position = pos ; target = pos
	$CollisionShape2D.disabled = false
	show()




func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target = event.position
		rotation = position.angle_to_point(target)
		$move_particles.emitting = true




func _process(delta):
	var velocity = Vector2()

	if position.distance_to(target) > 10:
		velocity = target - position

	if velocity.length() > 0 and is_visible_in_tree():
		velocity = velocity.normalized() * speed
		$Sprite/AnimationPlayer.play("player")
		if not $PlayerMove.playing:
			$PlayerMove.play()
	else:
		$Sprite/AnimationPlayer.stop()
		$move_particles.emitting = false
		$PlayerMove.stop()

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
			$move_particles.restart()
