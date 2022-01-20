extends Node2D

var BG_amount     = 14
var default_range = 8000


var ACTIVE
var ROTATE
var SCALE
var COLOR
var CHANGE


func _ready():
	ACTIVE = false
	ROTATE = false
	SCALE  = false
	COLOR  = false
	CHANGE = false

	yield(get_tree().create_timer(.1), "timeout")
	if z_index != 100:
		$Sprite.self_modulate = Color(.12, .28, .64, .84)
	else:
		$Sprite.self_modulate = Color(.18, .24, .62, .22)
	assign_tex()
	ACTIVE = true




func _process(_delta):
	var time ; var delay ; var rot ; var R ; var G ; var B ; var A ; var color

	if ACTIVE:
		if not ROTATE:
			ROTATE = true
			time  = rand_range(120, 240)
			delay = rand_range(4, 10)
			rot = randi() % 361 # ; rot = -rot if rot > 0 else rot
			$anim_rotate.interpolate_property($Sprite, "rotation_degrees",
				$Sprite.rotation_degrees, rot, time,
				Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
			$anim_rotate.start()
		elif not COLOR and not CHANGE:
			COLOR = true
			time  = rand_range(4, 8)
			delay = rand_range(6, 12)
			R = rand_range(.20, .32)
			G = rand_range(.28, .56)
			B = rand_range(.42, .94)
			A = rand_range(.70, .82) if z_index != 100 else rand_range(.18, .32)
			$anim_color.interpolate_property($Sprite, "self_modulate",
				$Sprite.self_modulate, Color(R,G,B,A), time,
				Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
			$anim_color.start()
		elif not SCALE:
			SCALE = true
			time  = rand_range(18, 42)
			delay = rand_range(6, 14)
			var scale = rand_range(6.64, 12)
			$anim_scale.interpolate_property($Sprite, "scale",
				$Sprite.scale, Vector2(scale, scale), time,
				Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
			$anim_scale.start()
		elif randi() % default_range + 1 >= default_range - 4 and CHANGE == false:
			CHANGE = true
			time  = rand_range(12, 18)
			delay = rand_range(4, 10)
			color = $Sprite.self_modulate ; color.a = 0
			$anim_color.remove($Sprite, "self_modulate")
			$anim_color.interpolate_property($Sprite, "self_modulate",
				$Sprite.self_modulate, color, time,
				Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
			$anim_color.start()




func _on_anim_rotate_end():
	ROTATE = false


func _on_anim_scale_end():
	SCALE = false


func _on_anim_color_end():
	COLOR = false
	if CHANGE:
		assign_tex()
		CHANGE = false




func assign_tex():
	#print("BG CHANGED")
	var path = "res://assets/level_bg/bg" + str(floor(rand_range(1, BG_amount)))
	$Sprite.texture = load(path +".png")
	if z_index != 100:
		$Sprite.normal_map = load(path +"_n.png")
	#print("z_index: "+ str(z_index) +"    light_mask: "+ str(light_mask))