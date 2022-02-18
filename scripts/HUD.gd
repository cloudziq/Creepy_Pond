extends CanvasLayer


signal start_game
signal toggle_title_anim

export var show_FPS_counter   := false

onready var main_menu_visible := true

var MessageFade
var buttons_sound_allow    #### to prevent playing button sounds on start




func _ready():
	$Message.hide()
	$PauseLayer/PAUSE.hide()
	$CREDITS.hide()
	$ScoreLabel.text = ""
	$MenuLightEffects/AnimationPlayer.play("light_move")

	yield(get_tree().create_timer(.1), "timeout")
	if get_parent().SETTINGS["score_record"] != 0:
		$ScoreLabel.text = "BEST SCORE:  " + str(get_parent().SETTINGS["score_record"])

	buttons_sound_allow = false
	var node_path = "VBoxContainer/MiddleButtons/HBoxContainer/"
	if get_parent().SETTINGS["music_mute"] == true:
		get_node(node_path +"ButtonMusic").pressed = true
	if get_parent().SETTINGS["sound_mute"] == true:
		get_node(node_path +"ButtonSound").pressed = true
	buttons_sound_allow = true

	Fade.fade_in(.6, Color.black, "GradientVertical", false, true)




func _input(event):
	if event.is_action_pressed("pause") and main_menu_visible == false:
		$PauseLayer/PAUSE.show()
		$PauseSound.pitch_scale = .68 ; $PauseSound.play()
		get_tree().paused = true




func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()




func update_score(score, mod):
	$ScoreLabel.text = str(score)
	if mod:
		var size = $ScoreLabel.rect_scale

		$Tween.interpolate_property($ScoreLabel, "rect_scale",
			size, size * 1.8, .25,
			Tween.TRANS_SINE, 0)
		$Tween.interpolate_property($ScoreLabel, "rect_scale",
			size * 1.8, size, 1,
			Tween.TRANS_SINE, Tween.EASE_OUT, .25)
		$Tween.start()

	if show_FPS_counter:
		$FPS_DISPLAY.text = str(Performance.get_monitor(Performance.TIME_FPS))




func show_game_over():
	$Message.add_color_override("font_color", Color(.56, .20, .18))
	show_message("GAME OVER")
	$Message/AnimationPlayer.playback_speed = .6
	$Message/AnimationPlayer.play("message_anim")
	yield($MessageTimer, "timeout")
	$ScoreLabel.set("custom_colors/font_color", Color(0,0,0,1))
	$ScoreLabel.text = "BEST SCORE:  " + str(get_parent().SETTINGS["score_record"])
	for node in get_tree().get_nodes_in_group("main_menu"):
		node.show()
	emit_signal("toggle_title_anim")
	main_menu_visible = true
	$FPS_DISPLAY.text = ""
	Fade.fade_in(1.2, Color.black, "Noise", false, true)




func _on_StartButton_pressed():
	yield(get_tree().create_timer(0.12), "timeout")
	Fade.fade_in(1.6, Color.black)
	for node in get_tree().get_nodes_in_group("main_menu"):
		node.hide()
	emit_signal("start_game")
	$Message.add_color_override("font_color", Color(.18, .40, .16))
	MessageFade = true ; show_message("Avoid the creeps")
	$Message/AnimationPlayer.stop()
	$Message/AnimationPlayer.playback_speed = 1
	$Message/AnimationPlayer.play("message_anim")
	$ButtonClick.play()
	$ScoreLabel.text = ""
	main_menu_visible = false
	emit_signal("toggle_title_anim")




func _on_CreditsButton_pressed():
	$CREDITS.show()
	$ButtonClick.play()
	$CREDITS/AnimationPlayer.play("credits window show")


func _on_Credits_BackButton_pressed():
	$CREDITS/AnimationPlayer.play("credits window hide")
	$ButtonClick.play()




func _on_MessageTimer_timeout():
	if MessageFade:
		var color = $Message.modulate ; color.a = 0

		$Tween.interpolate_property($Message, "modulate",
			$Message.modulate, color, 1,
			Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
	else:
		$Message.hide()




func _on_ResumeButton_pressed():
	$PauseLayer/PAUSE.hide()
	$ButtonClick.play()
	$PauseSound.pitch_scale = 1 ; $PauseSound.play()
	get_tree().paused = false




func _on_Tween_completed(_object, key):
	match str(key):
		":modulate":
			MessageFade = false
			$Message.hide()
			$Message.modulate = Color(1,1,1,1)




func _on_ButtonMusic_toggled(button_pressed):
	var node = $VBoxContainer/MiddleButtons/HBoxContainer/ButtonMusic/disabled
	process_button(node, "Music", button_pressed)


func _on_ButtonSound_toggled(button_pressed):
	var node = $VBoxContainer/MiddleButtons/HBoxContainer/ButtonSound/disabled
	process_button(node, "Sound", button_pressed)


func process_button(node, type, button_state):
	var texture_overlay = load("res://assets/menus/button_OFF.png")
	var busID = AudioServer.get_bus_index(type)
	get_parent().SETTINGS[str(type).to_lower() +"_mute"] = true if button_state else false
	get_parent().save_config()

	if button_state:
		node.texture = texture_overlay
		create_button_audio(.2, -22)
		AudioServer.set_bus_mute(busID, true)
	else:
		node.texture = null
		create_button_audio(1, -8)
		AudioServer.set_bus_mute(busID, false)


func create_button_audio(pitch, volume):
	if buttons_sound_allow:
		var audio = AudioStreamPlayer.new() ; add_child(audio)
		audio.stream      = load("res://assets/sounds/ButtonClick.ogg")
		audio.pitch_scale = pitch
		audio.volume_db   = volume
		audio.play() ; yield(audio, "finished") ; audio.queue_free()
