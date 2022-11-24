extends Area2D


signal hit
signal bonus_collected

export var SPEED         := 100.0
export var TONGUE_LENGTH := 80.0
export var TONGUE_TIME   := 1.0   # IN SECONDS

onready var screen_size        = get_viewport_rect().size
onready var path_line : Line2D = get_parent().get_node("PlayerDest")
onready var tongue    : Line2D = get_parent().get_node("Tongue")

var dest_target   := Vector2()
var tongue_target := Vector2()




func _ready():
	set_process(false)
	hide()

	if OS.get_name() == "HTML5":
		$move_particles.amount = 32




func start(pos):
	position = pos ; dest_target = pos
	$CollisionShape2D.disabled = false
	$PlayerMove.pitch_scale = .9
	set_process(true)
	show()




func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		dest_target = event.position
		rotation = position.angle_to_point(dest_target)
		$move_particles.emitting = true
	elif event.is_action_pressed("key2"):
		tongue_use()




func _process(dt):
	var velocity = Vector2()

	if position.distance_to(dest_target) > 10:
		path_line.points = PoolVector2Array([position, dest_target])
		path_line.show()
		velocity = dest_target - position

	if velocity.length() > 0 and is_visible_in_tree():
		velocity = velocity.normalized() * SPEED
		$Sprite/AnimationPlayer.play("player")
		if not $PlayerMove.playing:
			$PlayerMove.play()
	else:
		$Sprite/AnimationPlayer.stop()
		$move_particles.emitting = false
		$PlayerMove.stop()
		path_line.hide()

	position += velocity * dt
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)




func tongue_use():
	tongue_target = position + Vector2(-TONGUE_LENGTH, 0).rotated(rotation)
	dest_target = position
	tongue.points = PoolVector2Array([position, tongue_target])
	tongue.show()





func _on_player_body_entered(body):
	match body.get_groups():
		["bonus", ..]:
			emit_signal("bonus_collected")
		["mobs", ..]:
			emit_signal("hit")
			set_process(false)
			$PlayerMove.stop()
			$CollisionShape2D.set_deferred("disabled", true)
#			yield(get_tree().create_timer(1), "timeout")
			$move_particles.restart()
			for a in $pill_particles.get_children(): a.emitting = false
			hide()
