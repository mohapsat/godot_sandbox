extends Area2D

var timer = Timer.new()
var dmg = 100
var exception = []

var sounds = [preload("res://sounds/space_shield_sounds/space_shield_sounds-1.wav"),preload("res://sounds/space_shield_sounds/space_shield_sounds-2.wav"),preload("res://sounds/space_shield_sounds/space_shield_sounds-3.wav"),preload("res://sounds/space_shield_sounds/space_shield_sounds-4.wav"),preload("res://sounds/space_shield_sounds/space_shield_sounds-5.wav"),preload("res://sounds/space_shield_sounds/space_shield_sounds-6.wav"),preload("res://sounds/space_shield_sounds/space_shield_sounds-7.wav"),preload("res://sounds/space_shield_sounds/space_shield_sounds-8.wav"),preload("res://sounds/space_shield_sounds/space_shield_sounds-9.wav")]


func _disable():
	timer.queue_free()
	set_collision_mask(0)
	set_collision_layer(0)
	get_parent().set_collision_mask(3)
	get_parent().set_collision_layer(3)
	set_process(false)
	UI.get_node("Weapon/Bar/Animation").play("hide")

func _sound():
	get_node("Sound").set_stream(sounds[randi()%(sounds.size())])
	get_node("Sound").play()

func _process(delta):
	var bodies = get_overlapping_bodies()
	var areas = get_overlapping_areas()
	
	UI.get_node("Weapon/Bar").set_value(6.0-get_node("Animation").get_current_animation_position())
	
	for c in bodies:
		if !(c in exception):
			if (c.has_method("damaged")):
				c.damaged(dmg,true)
			elif (c.has_method("_disable")):
				c._disable()
			exception.push_back(c)
	for c in areas:
		if (c.has_method("_disable")):
			c._disable()

func _ready():
	timer.set_wait_time(0.9)
	add_child(timer)
	timer.connect("timeout",self,"_sound")
	timer.start()
	set_process(true)
	UI.get_node("Weapon/Bar").set_max(6.0)
	UI.get_node("Weapon/Bar").set_value(6.0)
	UI.get_node("Weapon/Bar/Animation").play("show")
	get_parent().set_collision_mask(0)
	get_parent().set_collision_layer(0)
	_sound()
	if (OS.has_feature("web")):
		get_node("BackBufferCopy").queue_free()
