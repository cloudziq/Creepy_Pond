extends Node


var mob_sound_count      : int
var mob_sound_max_amount := 12

var BG_in_folder  := 24
var BG_table      := []

var SETTINGS
var save_version = 1
var config_path
# userdata path: "user://config.cfg"     -- for mobile




func load_BGs():
	var path = "res://assets/level_bg/bg"

	for a in BG_in_folder:
		BG_table.append([])
		BG_table[a] = [
			load(path + str(a+1) +".png"),
			load(path + str(a+1) +"_n.png")
		]




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
		"HTML5":
			config_path = "user://config.cfg"

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
