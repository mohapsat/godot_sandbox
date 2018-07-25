extends Node2D

export var dmg = 1
export var lifetime = 0.25
var lv = Vector2(0,0)
var disabled = false

onready var raycast = get_node("RayCast")


func _destroy(impact=false):
	if (disabled):
		return

	disabled = true
	raycast.set_enabled(false)
	set_physics_process(false)
	if (impact):
		get_node("Animation").play("impact")
		get_node("Sound").play()
	else:
		get_node("Animation").play("fade_out")

func _physics_process(delta):
	var pos = get_position()
	var _lv = lv
	if (get_parent().has_meta("lv")):
		_lv += get_parent().lv
	translate(delta*_lv)
	raycast.set_cast_to(pos-position)

	if (raycast.is_colliding()):
		set_position(raycast.get_collision_point())
		if (raycast.get_collider().has_method("damaged")):
			raycast.get_collider().damaged(dmg,true)
		_destroy(true)

func _ready():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(lifetime)
	add_child(timer)
	timer.connect("timeout",self,"_destroy",[false])
	timer.start()
