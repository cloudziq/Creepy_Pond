extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	num()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func num():
	print(randi() % 10 + 1)
	yield(get_tree().create_timer(.25),"timeout")
	num()
