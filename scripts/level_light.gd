extends Node2D

export var is_vertical = 0


var screen_w ; var screen_h


var CHANGE = true




func _ready():
	screen_w = get_viewport().size.x
	screen_h = get_viewport().size.y

	yield(get_tree().create_timer(.1), "timeout")

	if is_vertical:
		$Light.rotation_degrees = 90
		$Light.scale = Vector2(4, 5)
	$light_height_timer.start()




func _process(_delta):
	var position_x ; var position_y ; var time ; var pos_mod

	if CHANGE:
		CHANGE = false
		if is_vertical:
			pos_mod = (screen_w / 4)
			pos_mod = pos_mod if randi() % 2 + 1 == 1 else -pos_mod
			position_x = (screen_w / 2) + pos_mod
			position_y = rand_range(0, screen_h)
			time = rand_range(4, 8)
		else:
			pos_mod = (screen_h / 6)
			pos_mod = pos_mod if randi() % 2 + 1 == 1 else -pos_mod
			position_x = rand_range(0, screen_w)
			position_y = (screen_h / 2) + pos_mod
			time = rand_range(4, 7)

		$light_pos.interpolate_property($Light, "position",
			$Light.position, Vector2(position_x, position_y), time,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT, rand_range(.8, 2.2))
		$light_pos.start()




func _on_light_pos_end():
	CHANGE = true


func _on_light_height_end():
	$light_height_timer.start()


func _on_light_height_timer_timeout():
	$light_height.interpolate_property($Light, "range_height",
		$Light.range_height, rand_range(60, 420), rand_range(6, 12),
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, rand_range(2, 6))
	$light_height.start()
