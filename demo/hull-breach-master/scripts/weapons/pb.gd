extends Area2D

export var dmg = 6
export var lifetime = 0.5
var lv = Vector2(0,0)
var disabled = false

func _destroy(impact=false):
	if (disabled):
		return
	
	disabled = true
	set_collision_mask(0)
	set_collision_layer(0)
	set_physics_process(false)
	if (impact):
		get_node("Animation").play("impact")
		get_node("Sound").play()
	else:
		get_node("Animation").play("fade_out")

func _physics_process(delta):
	var _lv = lv
	if (get_parent().has_meta("lv")):
		_lv += get_parent().lv
	translate(delta*_lv)
	
	for c in get_overlapping_bodies():
		if (c.has_method("damaged")):
			c.damaged(dmg,true)
		_destroy(true)

func _ready():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(lifetime)
	add_child(timer)
	timer.connect("timeout",self,"_destroy",[false])
	timer.start()
	if (OS.has_feature("web")):
		get_node("Sprite/BackBufferCopy").queue_free()
