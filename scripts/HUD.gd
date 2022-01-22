extends CanvasLayer

signal start_game




func _ready():
	$Message.hide()
	$ScoreLabel.text = ""

	yield(get_tree().create_timer(.1), "timeout")
	if get_parent().score_record != 0:
		$ScoreLabel.text = "BEST SCORE:  " + str(get_parent().score_record)




func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()




func update_score(score):
	$ScoreLabel.text = str(score)




func show_game_over():
	$Message.add_color_override("font_color", Color(1, 1, 1))
	show_message("GAME OVER :(")

	yield($MessageTimer, "timeout")
	$Message.add_color_override("font_color", Color(.14, .64, .8))

	yield(get_tree().create_timer(1), "timeout")
	$ScoreLabel.text = "BEST SCORE:  " + str(get_parent().score_record)
	for node in get_tree().get_nodes_in_group("main_menu"):
		node.show()




func _on_StartButton_pressed():
	for node in get_tree().get_nodes_in_group("main_menu"):
		node.hide()
	emit_signal("start_game")
	show_message("Avoid the Creeps!")
	$ButtonClick.play()
	$ScoreLabel.text = ""





func _on_MessageTimer_timeout():
	$Message.hide()
