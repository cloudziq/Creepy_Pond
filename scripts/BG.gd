extends TextureRect


var BG_amount     = 64
var default_range = 2600

var active
var rotate
var scale
var color
var change


func _ready():
	active = true
	rotate = false
	scale  = false
	color  = true
	change = false




func _process(_delta):
	if not rotate:
		rotate = true
		var time  = rand_range(60, 140)
		var delay = rand_range(4, 12)
		$Tween.interpolate_property($BG, "rect_rotation",
		$BG.rect_rotation, randi() % 361, time,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
