extends Node2D

export(PackedScene) var Mob        ; var mob
export(PackedScene) var bonus_item ; var bonus
export(PackedScene) var BG_scene
export(PackedScene) var level_light


#var default_player_speed
#var default_playback_speed
var score = 0 ; var score_record = 0
var allow_bonus_spawn
var allow_clock_spawn
var allow_pill_spawn
var allow_mob_spawn

onready var default_player_speed   = $player.speed
onready var default_playback_speed = $player/Sprite/AnimationPlayer.playback_speed
onready var default_pill_bonus_wait_time = $Timers/PillBonusDelay.wait_time




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
		else:
			BG.z_index = 0

	for a in lights_num:
		var light = level_light.instance()
		add_child(light)
		if a >= lights_num - 2:
			light.is_vertical = 1

	window_prepare()
	load_config()





func _process(_delta):
	if allow_bonus_spawn:
		allow_bonus_spawn = false
		bonus = bonus_item.instance()
		add_child(bonus)
		$Sounds/bonus_appear.pitch_scale = rand_range(.8, 1.2)
		$Sounds/bonus_appear.play()




func new_game():
	score = 0
	$player.speed = default_player_speed
	$player/Sprite/AnimationPlayer.playback_speed = default_playback_speed
	$Timers/PillBonusDelay.wait_time = default_pill_bonus_wait_time
	allow_mob_spawn   = true
	allow_bonus_spawn = false
	allow_clock_spawn = false
	allow_pill_spawn  = false
	$player.start($StartPosition.position)
	$Timers/StartTimer.start()
	$Timers/BonusDelay.wait_time = 4 ; $Timers/BonusDelay.start()
	$Timers/ClockBonusDelay.start()
	$Timers/PillBonusDelay.start()
	$Sounds/level_music.play()
	$Timers/MobTimer.wait_time = 1




func game_over():
	if score > SETTINGS["score_record"]:
		SETTINGS["score_record"] = score
		save_config()
#	allow_bonus_spawn = false
	$HUD.show_game_over()
	$Timers/ScoreTimer.stop()
	$Timers/MobTimer.stop()
	$Timers/BonusDelay.stop()
	$Sounds/level_music.stop()
	$Sounds/enemy_bite.play()
	get_tree().call_group("mobs",  "queue_free")
	get_tree().call_group("bonus", "queue_free")
	yield(get_tree().create_timer(.8), "timeout")
	$Sounds/death_sound.play()
	$Sounds/clock_ticking.stop()




var SETTINGS
var save_version = 1
var config_path
# userdata path: "user://config.cfg"     -- for mobile

func save_config():
	var password = "7846536587438346574"
	var key = password.sha256_buffer()
	var config = ConfigFile.new()

	config.set_value("main", "save_version", save_version)
	config.set_value("main", "settings", SETTINGS)


#	config.save(config_path)
	config.save_encrypted(config_path, key)




func load_config():
	var password = "7846536587438346574"
	var key = password.sha256_buffer()
	var config = ConfigFile.new()

	var system = OS.get_name()
	match system:
		"Windows", "X11":
			config_path = OS.get_executable_path().get_base_dir() + "/config.cfg"

#	var err = config.load(config_path)
	var err = config.load_encrypted(config_path, key)
	if err != OK or config.get_value("main", "save_version") != save_version:
		SETTINGS = {
			"sound_mute"   : false,
			"music_mute"   : false,
			"score_record" : 0
		}
	else:
		SETTINGS = config.get_value("main", "settings")




func window_prepare():
	var display_size = OS.get_screen_size()
	var window_size = OS.window_size
	window_size.x *= 4 ; window_size.y *= 4

	if display_size.y <= window_size.y:
		var scale_ratio = window_size.y / (display_size.y - 100)
		window_size.x /= scale_ratio ; window_size.y /= scale_ratio

	OS.set_window_size(window_size)
	window_size.y += 80
	OS.set_window_position(display_size * .5 - window_size * .5)








func _on_MobTimer_timeout():
	if allow_mob_spawn:
		mob = Mob.instance()
		add_child(mob)




func _on_StartTimer_timeout():    ## After intro message
	$Timers/MobTimer.start()
	$Timers/ScoreTimer.start()




func _on_ScoreTimer_timeout():
	if $Timers/MobTimer.wait_time > .1 and $Timers/MobClockDelay.is_stopped():
		$Timers/MobTimer.wait_time -= $Timers/MobTimer.wait_time / 86
	score += 1
	$HUD.update_score(score, false)
#	print($Timers/MobTimer.wait_time)




func _on_MobClockDelay_timeout():
	$Sounds/clock_ticking.stop()
	$HUD/ScoreLabel.set("custom_colors/font_color", Color(0,0,0,1))
	allow_mob_spawn = true




func _on_player_bonus_collected():
	bonus.queue_free()
	$Timers/BonusDelay.start()

	match bonus.bonuses[bonus.bonus_type][0]:
		"point":
			score += 1
			$HUD.update_score(score, true)
			$Sounds/bonus_point_collect.pitch_scale = rand_range(.6, 1.4)
			$Sounds/bonus_point_collect.play()
		"speed_pill":
			$Sounds/bonus_pill_collect.play()
			$Timers/PillBonusDelay.wait_time += 2
			$Timers/PillBonusDelay.start()
			$player/pill_particles/big.emitting   = true
			$player/pill_particles/small.emitting = true
			$player.speed *= 1.1
			$player/Sprite/AnimationPlayer.playback_speed *= 1.1
		"clock":
			var default_timer = 8
			var time = default_timer * (1 + (1 - ($Timers/MobTimer.wait_time * 1.6)))
			#print("CLOCK TIME:" + ("%.2f" % time))
			$Timers/MobClockDelay.wait_time = time
			$Timers/MobClockDelay.start()
			$Timers/ClockBonusDelay.start()
			$Sounds/bonus_clock_collect.play()
			$Sounds/clock_ticking.play()
			$HUD/ScoreLabel.set("custom_colors/font_color", Color(0, .6, 0, 1))
			mob.time_scale("reduce")
			allow_mob_spawn = false




func _on_BonusDelay_timeout():
	if $Timers/BonusDelay.wait_time == 4:
		$Timers/BonusDelay.wait_time = 1
	allow_bonus_spawn = true


func _on_ClockBonusDelay_timeout():
	allow_clock_spawn = true


func _on_PillBonusDelay_timeout():
	allow_pill_spawn = true
