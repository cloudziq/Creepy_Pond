extends KinematicBody2D


export var min_speed      := 34.0
export var max_speed      := 68.0
export var max_turn_angle := 65.0

onready var mob_timer = get_parent().get_node("Timers/MobTimer").wait_time

const mob_sound = [
	preload("res://assets/sounds/MobSound.wav"),
	preload("res://assets/sounds/MobSound2.wav")
]

enum mob_modes {STRAIGHT, ANGULAR}
var mob_mode       : int
var current_turn   := 0
var mob_turn_angle := 0.0
var mob_turn_speed := 1.6
var time_to_turn   := 0.0

var speed_min
var speed_max
var speed
var velocity := Vector2()




func _ready():
	#### DETERMINE MOB MOVEMENT TYPE
	var base_probability = .2
	var modifier         = mob_timer / 10
	var probability      = randf() + modifier
	if probability < base_probability and mob_timer < .8:
		mob_mode = mob_modes.ANGULAR
	else:
		mob_mode = mob_modes.STRAIGHT

	var MobSpawn  = get_parent().get_node("MobPath/MobSpawnLocation")
	var timer     = get_parent().get_node("Timers/MobTimer")
	var mob_anims = $Sprite/AnimationPlayer.get_animation_list()

	MobSpawn.offset = randi()
	z_index = 10

	# randomize scale
	var scale_min = .12 ; var scale_max = .18
	var scale_mid = (scale_min + scale_max) / 2
	var scale_new = rand_range(scale_min, scale_max)
	$Sprite.scale = (Vector2(scale_new, scale_new))
	$CollisionShape2D.scale = (Vector2(scale_new, scale_new))
	$MobSoundEnabler/CollisionShape2D.scale = (Vector2(scale_new, scale_new))
	$move_particles.scale = Vector2(scale_new * 6, scale_new * 5)
	$move_particles.set("scale_amount", 0.16 * (.32 - scale_new))
	$move_particles.amount = 200 * mob_timer * 1.4

	# Set the mob's direction perpendicular to the path direction.
	var direction = MobSpawn.rotation + PI / 2
	# Set the mob's position to a random location and add some randomness
	position = MobSpawn.position
	direction += rand_range(-PI / 4, PI / 4)
	rotation = direction - PI

	# Set the velocity (speed & direction).
	speed_min = min_speed * (1 + (1 - timer.wait_time)) ; speed_min += (speed_min * .1)
	speed_max = max_speed * (1 + (1 - timer.wait_time)) ; speed_max += (speed_max * .2)
#	print("min: "+ ("%.2f" % speed_min) +"    max: "+ ("%.2f" % speed_max))
	speed = rand_range(speed_min, speed_max)

	var R ; var G ; var B
	match mob_mode:
		mob_modes.STRAIGHT:
			R = rand_range(.72, .90)
			G = rand_range(.62, .99)
			B = rand_range(.32, .44)
			$Sprite/AnimationPlayer.play(mob_anims[rand_range(1, mob_anims.size() - 1)])
			$Sprite/AnimationPlayer.playback_speed = .4 + (speed / 100)
			$MobSound.stream = mob_sound[0]
			var pitch = 1.2 - scale_new if scale_new >= scale_mid else 1.2 + scale_new
			$MobSound.pitch_scale += pitch
		mob_modes.ANGULAR:
			R = rand_range(.7,  1)
			G = rand_range(.6, .9)
			B = rand_range(.4, .6)
			$Sprite/AnimationPlayer.play("enemy3")
			$Sprite/AnimationPlayer.playback_speed = 6 + (speed / 100)
			$MobSound.stream = mob_sound[1]
			$MobSound.pitch_scale = .4 + (speed / 100)
	$Sprite.self_modulate = Color(R,G,B)

	if OS.get_name() == "HTML5":
		$move_particles.hide()
		$clock_particles.hide()




func _physics_process(delta):
	velocity = Vector2(1,0).rotated(rotation - PI) * speed * delta
	# warning-ignore:return_value_discarded
	move_and_collide(velocity)




func _process(_delta):
	var time = OS.get_system_time_msecs()

	if mob_mode == mob_modes.ANGULAR and time > time_to_turn:
		time_to_turn = time + (mob_turn_speed * 1000 + 50) * (1 - mob_timer)
		match current_turn:
			0:
				mob_turn_angle = deg2rad(rand_range(12, max_turn_angle * (1 - mob_timer)))
				rotation += mob_turn_angle
				current_turn = 1
			1:
				$Tween.interpolate_property($".", "rotation",
					rotation, rotation - mob_turn_angle * 2, mob_turn_speed * (1 - mob_timer),
					Tween.TRANS_SINE, Tween.EASE_IN_OUT)
				$Tween.start()
				current_turn = 2
			2:
				$Tween.interpolate_property($".", "rotation",
					rotation, rotation + mob_turn_angle * 2, mob_turn_speed * (1 - mob_timer),
					Tween.TRANS_SINE, Tween.EASE_IN_OUT)
				$Tween.start()
				current_turn = 1




func time_scale(effect):
	var scale = 2.0 if effect == "normal" else .5
	for instance in get_tree().get_nodes_in_group("mobs"):
		instance.speed *= scale
		instance.mob_turn_speed *= 2
		instance.get_node("clock_particles").emitting = true
		instance.get_node("Sprite/AnimationPlayer").playback_speed *= .5
		$MobSound.pitch_scale *= .5
#		$MobSound.stop() ; $MobSound.play()




func _on_VisibilityNotifier2D_screen_exited():
	queue_free()




func _on_MobSoundEnabler_area_entered(_area):
	Util.mob_sound_count += 1
	if Util.mob_sound_count <= Util.mob_sound_max_amount:
		$MobSound.play()


func _on_MobSoundEnabler_area_exited(_area):
	Util.mob_sound_count -= 1
	$MobSound.stop()
