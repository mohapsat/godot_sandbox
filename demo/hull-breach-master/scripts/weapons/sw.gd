extends Area2D

var dmg = 100
export var radius = 256
var exception = []


func _disable():
	set_collision_mask(0)
	set_collision_layer(0)
	set_process(false)
	UI.get_node("Weapon/Bar/Animation").play("hide")

func _explode():
	set_process(true)

func _process(delta):
	var pos = get_global_position()
	var r2 = radius*radius
	var bodies = get_overlapping_bodies()
	var areas = get_overlapping_areas()
	
	UI.get_node("Weapon/Bar").set_value(get_node("Animation").get_current_animation_position())
	
	for c in bodies:
		if (pos.distance_squared_to(c.get_global_position())<=r2 && !(c in exception)):
			if (c.has_method("damaged")):
				c.damaged(dmg)
			exception.push_back(c)
	for c in areas:
		if (pos.distance_squared_to(c.get_global_position())<=r2 && c.has_method("_destroy")):
			c._destroy()

func _ready():
	set_process(true)
	UI.get_node("Weapon/Bar").set_max(0.7)
	UI.get_node("Weapon/Bar").set_value(0.0)
