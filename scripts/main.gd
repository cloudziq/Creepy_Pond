extends Node2D

export(PackedScene) var Mob ; var mob
export(PackedScene) var bonus_item ; var bonus
export(PackedScene) var BG_scene ; var BG


var score
var allow_bonus_spawn = false
var allow_mob_spawn   = true




func _ready():
	randomize()




func _process(_delta):
	if allow_bonus_spawn:
		var a = randi() % 201
		if a == 200:
			bonus = bonus_item.instance()
			add_child(bonus)
			allow_bonus_spawn = false




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
		var R = rand_range(.28, .48)
		var G = rand_range(.5,  .86)
		var B = rand_range(.36, .82)
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
		print("min: "+ ("%.2f" % speed_min) +"    max: "+ ("%.2f" % speed_max))
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
	allow_mob_spawn = true




func _on_player_bonus_collected():
	$Sounds/point_collected.play()
	bonus.queue_free()
	allow_bonus_spawn = true

	match bonus.bonuses[bonus.bonus_type][0]:
		"point":
			score += 1
			$HUD.update_score(score)
		"clock":
			var time
			var default_timer = 8
			mob.time_scale("reduce")
			time = default_timer * (1 + (1 - ($Timers/MobTimer.wait_time * 2)))
			print("CLOCK TIME:" + ("%.2f" % time))
			$Timers/MobClockDelay.wait_time = time
			$Timers/MobClockDelay.start()
			allow_mob_spawn = false
