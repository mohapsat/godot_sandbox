extends Area2D

var dmg = 6
var lv = Vector2(0,0)
var la = 1500.0
var target
var frame = 0
var frames = 0
var disabled = false

var sounds = [preload("res://sounds/explosions/explosion01.wav"),preload("res://sounds/explosions/explosion02.wav"),preload("res://sounds/explosions/explosion03.wav"),preload("res://sounds/explosions/explosion04.wav"),preload("res://sounds/explosions/explosion05.wav"),preload("res://sounds/explosions/explosion06.wav"),preload("res://sounds/explosions/explosion07.wav"),preload("res://sounds/explosions/explosion08.wav"),preload("res://sounds/explosions/explosion09.wav")]


func _disable():
	if (disabled):
		return
	
	disabled = true
	set_collision_layer(0)
	set_collision_mask(0)
	set_physics_process(false)
	get_node("Animation").play("fade_out")

func _explode(body=null):
	if (disabled):
		return
	
	disabled = true
	set_physics_process(false)
	get_node("Animation").play("explode")
	get_node("Sound").set_stream(sounds[randi()%sounds.size()])
	get_node("Sound").play()
	for c in get_node("Explosion").get_overlapping_bodies()+get_node("Explosion").get_overlapping_areas():
		c.damaged(dmg,true)

func damaged(dmg=1,by_player=false):
	_explode()

func find_target():
	var min_dist = 9999999.0
	target = null
	for e in get_node("/root/Level").enemy:
		var dist = global_position.distance_squared_to(e.get_global_position())/(4-abs(get_angle_to(e.get_global_position())))
		if (dist<min_dist):
			min_dist = dist
			target = e

func _physics_process(delta):
	var dir = Vector2(0,0)
	var rot = rotation
	if (target!=null && !target.disabled):
		dir = (target.get_global_position()-global_position).normalized()
		if (target.hp<=0):
			find_target()
	else:
		find_target()
		dir = lv.normalized()
	lv += delta*la*dir
	lv *= 0.95
	translate(delta*lv)
	set_rotation(lv.angle())
	frame -= delta*5*(rotation-rot)
	if (frame<=-0.5):
		frame += frames
	elif (frame>=frames-0.5):
		frame -= frames
	get_node("Sprite").set_frame(round(frame))

func _ready():
	var mat = get_node("Sprite").get_material().duplicate()
	var timer = Timer.new()
	get_node("Sprite").set_material(mat)
	timer.set_one_shot(true)
	timer.set_wait_time(10.0)
	add_child(timer)
	timer.connect("timeout",self,"_disable")
	timer.start()
	connect("body_entered",self,"_explode")
	connect("area_entered",self,"_explode")
	frames = get_node("Sprite").get_hframes()*get_node("Sprite").get_vframes()
	find_target()
	if (OS.has_feature("web")):
		get_node("BackBufferCopy").queue_free()
