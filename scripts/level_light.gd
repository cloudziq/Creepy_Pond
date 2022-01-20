extends Node2D


var screen_h
var screen_w

var CHANGE = true




func _ready():
	screen_h = get_viewport().size.x
	screen_w = get_viewport().size.y
	$light_height_timer.start()




func _process(_delta):
	if CHANGE:
		CHANGE = false
		var position_x = rand_range(0, screen_w)
		var position_y = screen_h / 2
		$light_pos.interpolate_property($Light, "position",
			$Light.position, Vector2(position_x, position_y), rand_range(3, 7),
			Tween.TRANS_SINE, Tween.EASE_IN_OUT, rand_range(2, 4))
		$light_pos.start()




func _on_light_pos_end():
	CHANGE = true


func _on_light_height_end():
	$light_height_timer.start()


func _on_light_height_timer_timeout():
#	$light_height.interpolate_property($Light, "range_height",
#		$Light.range_height, rand_range(60, 200), rand_range(6, 12),
#		Tween.TRANS_SINE, Tween.EASE_IN_OUT, rand_range(2, 6))
#	$light_height.start()
	pass
