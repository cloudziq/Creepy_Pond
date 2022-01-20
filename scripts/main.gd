extends Node2D

export(PackedScene) var Mob ; var mob
export(PackedScene) var bonus_item ; var bonus
export(PackedScene) var BG_scene ; var BG
export(PackedScene) var level_light ; var light


var score
var allow_bonus_spawn = false
var allow_mob_spawn   = true




func _ready():
	randomize()
	var num_of_BGs = 4
	var lights_num = 4

	for a in num_of_BGs:
		BG = BG_scene.instance()
		add_child(BG)
		if a == num_of_BGs - 1:
			BG.z_index = 100
			BG.light_mask = 2

	for a in lights_num:
		light = level_light.instance()
		add_child(light)




func _process(_delta):
	if allow_bonus_spawn:
		var a = randi() % 201
		if a == 200:
			bonus = bonus_item.instance()
			add_child(bonus)
			allow_bonus_spawn = false
			$Sounds/bonus_appear.pitch_scale = rand_range(.8, 1.2)
			$Sounds/bonus_appear.play()




func new_game():
	score = 0
	$player.start($StartPosition.position)
	$Timers/StartTimer.start()
	$Sounds/level_music.play()
	$HUD/Title.hide()




func game_over():   ## On player hit signal
	allow_bonus_spawn = false
	get_tree().call_group("mobs",  "queue_free")
	get_tree().call_group("bonus", "queue_free")
	$HUD.show_game_over()
	$Timers/ScoreTimer.stop()
	$Timers/MobTimer.stop()
	$Sounds/level_music.stop()
	$Sounds/enemy_bite.play()
	yield(get_tree().create_timer(.8), "timeout")
	$Sounds/death_sound.play()




func _on_MobTimer_timeout():
	if allow_mob_spawn:
		# Choose a random location on Path2D.
		$MobPath/MobSpawnLocation.offset = randi()

		# Create a Mob instance and add it to the scene.
		mob = Mob.instance()
		add_child(mob)

		# Randomize color a bit
		var R = rand_range(.72, .90)
		var G = rand_range(.62, .99)
		var B = rand_range(.32, .44)
		mob.get_node("AnimatedSprite").self_modulate = Color(R,G,B)

		# Set the mob's direction perpendicular to the path direction.
		var direction = $MobPath/MobSpawnLocation.rotation + PI / 2

		# Set the mob's position to a random location.
		mob.position = $MobPath/MobSpawnLocation.position

		# Add some randomness to the direction.
		direction += rand_range(-PI / 4, PI / 4)
		mob.rotation = direction

		# Set the velocity (speed & direction).
		var speed_min = mob.min_speed * (1 + (1 - $Timers/MobTimer.wait_time))
		var speed_max = mob.max_speed * (1 + (1 - $Timers/MobTimer.wait_time))
#		print("min: "+ ("%.2f" % speed_min) +"    max: "+ ("%.2f" % speed_max))
		mob.linear_velocity = Vector2(rand_range(speed_min, speed_max), 0)
		mob.linear_velocity = mob.linear_velocity.rotated(direction)




func _on_StartTimer_timeout():
	allow_bonus_spawn = true
	$Timers/MobTimer.wait_time = .8
	$Timers/MobTimer.start()
	$Timers/ScoreTimer.start()




func _on_ScoreTimer_timeout():
	if $Timers/MobTimer.wait_time > 0.20:
		$Timers/MobTimer.wait_time -= 0.006
	score += 1
	$HUD.update_score(score)




func _on_MobClockDelay_timeout():
	$Sounds/clock_ticking.stop()
	allow_mob_spawn = true




func _on_player_bonus_collected():
	bonus.queue_free()
	allow_bonus_spawn = true

	match bonus.bonuses[bonus.bonus_type][0]:
		"point":
			score += 1
			$HUD.update_score(score)
			$Sounds/point_collected.pitch_scale = rand_range(.6, 1.4)
			$Sounds/point_collected.play()
		"clock":
			var time
			var default_timer = 8
			mob.time_scale("reduce")
			time = default_timer * (1 + (1 - ($Timers/MobTimer.wait_time * 2)))
			#print("CLOCK TIME:" + ("%.2f" % time))
			$Timers/MobClockDelay.wait_time = time
			$Timers/MobClockDelay.start()
			$Sounds/bonus_collected.play()
			$Sounds/clock_ticking.play()
			allow_mob_spawn = false
