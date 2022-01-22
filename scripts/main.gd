extends Node2D

export(PackedScene) var Mob        ; var mob
export(PackedScene) var bonus_item ; var bonus
export(PackedScene) var BG_scene
export(PackedScene) var level_light

#export var allow_clock = false


var score = 0 ; var score_record = 0
var allow_bonus_spawn = false
var allow_clock_spawn = false
var allow_mob_spawn   = true




func _ready():
	randomize()
	var num_of_BGs = 4
	var lights_num = 4

	for a in num_of_BGs:
		var BG = BG_scene.instance()
		add_child(BG)
		if a == num_of_BGs - 1:
			BG.z_index = 100
			BG.light_mask = 2

	for a in lights_num:
		var light = level_light.instance()
		add_child(light)
		if a >= lights_num - 2:
			light.is_vertical = 1

	load_config()





func _process(_delta):
	if allow_bonus_spawn:
		bonus = bonus_item.instance()
		add_child(bonus)
		allow_bonus_spawn = false
		$Sounds/bonus_appear.pitch_scale = rand_range(.8, 1.2)
		$Sounds/bonus_appear.play()




func new_game():
	score = 0
	allow_clock_spawn = false
	$player.start($StartPosition.position)
	$Timers/StartTimer.start()
	$Timers/BonusDelay.start()
	$Timers/ClockBonusDelay.start()
	$Sounds/level_music.play()




func game_over():
	allow_bonus_spawn = false
	get_tree().call_group("mobs",  "queue_free")
	get_tree().call_group("bonus", "queue_free")
	$HUD.show_game_over()
	$Timers/ScoreTimer.stop()
	$Timers/MobTimer.stop()
	$Timers/BonusDelay.stop()
	$Sounds/level_music.stop()
	$Sounds/enemy_bite.play()
	yield(get_tree().create_timer(.8), "timeout")
	$Sounds/death_sound.play()
	$Sounds/clock_ticking.stop()
	if score > score_record:
		score_record = score
		save_config()




var save_version = 2

func save_config():
	var password = "7846536587438346574"
	var key = password.sha256_buffer()
	var config = ConfigFile.new()

	config.set_value("config", "save_version", save_version)
	config.set_value("config", "score_record", score_record)

#	config.save("user://config.cfg")
	config.save_encrypted("user://config.cfg", key)




func load_config():
	var password = "7846536587438346574"
	var key = password.sha256_buffer()
	var config = ConfigFile.new()

#	var err = config.load("user://config.cfg")
	var err = config.load_encrypted("user://config.cfg", key)
	if err != OK: return

	if config.get_value("config", "save_version") != save_version:
		score_record = 0
	else:
		score_record = config.get_value("config", "score_record")








func _on_MobTimer_timeout():
	if allow_mob_spawn:
		mob = Mob.instance()
		add_child(mob)




func _on_StartTimer_timeout():    ## After pressing Start Button
	$Timers/MobTimer.wait_time = .8
	$Timers/MobTimer.start()
	$Timers/ScoreTimer.start()




func _on_ScoreTimer_timeout():
	if $Timers/MobTimer.wait_time > .20:
		$Timers/MobTimer.wait_time -= $Timers/MobTimer.wait_time / 100
	score += 1
	$HUD.update_score(score)




func _on_MobClockDelay_timeout():
	$Sounds/clock_ticking.stop()
	allow_mob_spawn = true




func _on_player_bonus_collected():
	bonus.queue_free()
	$Timers/BonusDelay.start()

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
			$Timers/ClockBonusDelay.start()
			$Sounds/bonus_collected.play()
			$Sounds/clock_ticking.play()
			allow_mob_spawn = false




func _on_BonusDelay_timeout():
	if $Timers/BonusDelay.wait_time == 4:
		$Timers/BonusDelay.wait_time = 2
	allow_bonus_spawn = true




func _on_ClockBonusDelay_timeout():
	allow_clock_spawn = true
