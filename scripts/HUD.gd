extends CanvasLayer

signal start_game


export var show_FPS_counter = false

var main_menu_visible




func _ready():
	main_menu_visible = true
	$Message.hide()
	$PAUSE.hide()
	$ScoreLabel.text = ""

	yield(get_tree().create_timer(.1), "timeout")
	if get_parent().score_record != 0:
		$ScoreLabel.text = "BEST SCORE:  " + str(get_parent().score_record)



func _input(event):
	if event.is_action_pressed("pause") and main_menu_visible == false:
		$PAUSE.show()
		$PauseSound.pitch_scale = .68 ; $PauseSound.play()
		get_tree().paused = true





func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()




func update_score(score):
	$ScoreLabel.text = str(score)
	if show_FPS_counter:
		$FPS_DISPLAY.text = str(Performance.get_monitor(Performance.TIME_FPS))




func show_game_over():
	$Message.add_color_override("font_color", Color(1, 1, 1))
	show_message("GAME OVER :(")

	yield($MessageTimer, "timeout")
	$Message.add_color_override("font_color", Color(.14, .64, .8))

	yield(get_tree().create_timer(1), "timeout")
	$ScoreLabel.text = "BEST SCORE:  " + str(get_parent().score_record)
	for node in get_tree().get_nodes_in_group("main_menu"):
		node.show()
	main_menu_visible = true
	$FPS_DISPLAY.text = ""




func _on_StartButton_pressed():
	for node in get_tree().get_nodes_in_group("main_menu"):
		node.hide()
	emit_signal("start_game")
	show_message("Avoid the Creeps!")
	$ButtonClick.play()
	$ScoreLabel.text = ""
	main_menu_visible = false




func _on_MessageTimer_timeout():
	$Message.hide()


func _on_ResumeButton_pressed():
	$PAUSE.hide()
	$ButtonClick.play()
	$PauseSound.pitch_scale = 1 ; $PauseSound.play()
	get_tree().paused = false
