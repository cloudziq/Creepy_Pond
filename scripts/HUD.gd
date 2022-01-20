extends CanvasLayer

signal start_game




func _ready():
	$Message.hide()
	$ScoreLabel.text = ""




func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()




func update_score(score):
	$ScoreLabel.text = str(score)




func show_game_over():
	$Message.add_color_override("font_color", Color(1, 1, 1))
	show_message("GAME OVER :(")

#  Wait until the MessageTimer has counted down.
	yield($MessageTimer, "timeout")

	$Message.add_color_override("font_color", Color(.14, .64, .8))
	#$Message.text = "Avoid the Creeps!"

#  Make a one-shot timer and wait for it to finish.
	yield(get_tree().create_timer(1), "timeout")
	$StartButton.show()
	$Title.show()




func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")
	show_message("Avoid the Creeps!")
	$ScoreLabel.text = ""
	$Title.hide()





func _on_MessageTimer_timeout():
	$Message.hide()
