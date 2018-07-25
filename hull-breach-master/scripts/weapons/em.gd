extends Area2D

export var hp = 1
export var score = 4
export var la = 400.0
export var size = 0.5
var lv = Vector2(0,0)
var target
var frame = 0
var frames = 0
var time = 0.0
var disabled = false

var sounds = [preload("res://sounds/explosions/explosion01.wav"),preload("res://sounds/explosions/explosion02.wav"),preload("res://sounds/explosions/explosion03.wav"),preload("res://sounds/explosions/explosion04.wav"),preload("res://sounds/explosions/explosion05.wav"),preload("res://sounds/explosions/explosion06.wav"),preload("res://sounds/explosions/explosion07.wav"),preload("res://sounds/explosions/explosion08.wav"),preload("res://sounds/explosions/explosion09.wav")]


func _disable(anim="fade_out"):
	if (disabled):
		return
	
	disabled = true
	set_collision_layer(0)
	set_collision_mask(0)
	get_node("Explosion").set_collision_layer(0)
	get_node("Explosion").set_collision_mask(0)
	get_node("/root/Level").enemy.erase(self)
	set_physics_process(false)
	get_node("Animation").play(anim)

func damaged(dmg=1,by_player=false):
	_disable("explode")
	if (by_player):
		get_node("/root/Level").score += score

func _explode(body=null):
	if (disabled):
		return
	
	get_node("Sound").set_stream(sounds[randi()%sounds.size()])
	get_node("Sound").play()
	for c in get_node("Explosion").get_overlapping_bodies()+get_node("Explosion").get_overlapping_areas():
		if (c.has_method("damaged")):
			c.damaged(1)
	_disable("explode")

func _physics_process(delta):
	var dir = Vector2(0,0)
	var rot = rotation
	time += delta
	if (target!=null && !target.disabled):
		dir = (target.get_global_position()-global_position).normalized()
		if (target.hp<=0):
			target = null
	else:
		target = null
		dir = lv.normalized()
	lv += delta*la*dir.rotated(PI/4.0*sin(time))
	lv *= 0.975
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
	timer.set_wait_time(20.0)
	add_child(timer)
	timer.connect("timeout",self,"_disable")
	timer.start()
	connect("body_entered",self,"_explode")
	connect("area_entered",self,"_explode")
	get_node("/root/Level").enemy.push_back(self)
	frames = get_node("Sprite").get_hframes()*get_node("Sprite").get_vframes()
	if (has_node("/root/Level/Player")):
		target = get_node("/root/Level/Player")
	if (OS.has_feature("web")):
		get_node("BackBufferCopy").queue_free()
