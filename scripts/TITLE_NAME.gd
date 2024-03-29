extends CenterContainer


var title_length := [6, 4]
var def_pos      := {}
var allow        := true




func _ready():
	for row in title_length.size():
		for index in title_length[row]:
			var node = get_node("VBoxContainer" + "/row"+str(row+1) + "/"+str(index+1))
			if allow:
				if not def_pos.has(node):
					def_pos[node] = node.rect_position
				anim(node, false)
			else:
				$Tween.remove_all()
				node.rect_position = def_pos[node]




func anim(node, delay):
	var pos = def_pos[node]
	pos.x += rand_range(-4, 4)
	pos.y += rand_range(-4, 4)
	var delay_time := rand_range(.6, 1.2) if delay else 0.1

	$Tween.interpolate_property(node, "rect_position",
		node.rect_position, pos, rand_range(2, 4),
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay_time)
	$Tween.start()




func _on_Tween_completed(object, _key):
		anim(object, true)




func _on_HUD_toggle_title_anim():
	allow = not allow ; _ready()
