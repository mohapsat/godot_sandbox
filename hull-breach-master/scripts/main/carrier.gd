extends Node2D

var lv = Vector2(0,-25)


func _ready():
	set_process(true)

func _process(delta):
	translate(delta*lv)
