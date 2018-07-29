extends Node2D

var size = 0


func _process(delta):
	var pos = get_global_position()-get_node("/root/Level/Player").get_global_position()
	var rot = pos.angle()
	var l = pos.length()
	var length = 64.0
	pos = pos.normalized()*min(l,length)
	get_node("Sprite").set_global_position(get_node("/root/Level/Player").get_global_position()+pos)
	get_node("Sprite").set_global_rotation(rot)

func _ready():
	set_process(true)
	get_node("Sprite").set_frame(2*size-1)
