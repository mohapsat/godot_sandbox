extends Area2D

var dmg = 20
var lv = Vector2(0,0)
var frame = 0
var frames = 0
var disabled = false

var sounds = [preload("res://sounds/explosions/explosion01.wav"),preload("res://sounds/explosions/explosion02.wav"),preload("res://sounds/explosions/explosion03.wav"),preload("res://sounds/explosions/explosion04.wav"),preload("res://sounds/explosions/explosion05.wav"),preload("res://sounds/explosions/explosion06.wav"),preload("res://sounds/explosions/explosion07.wav"),preload("res://sounds/explosions/explosion08.wav"),preload("res://sounds/explosions/explosion09.wav")]


func _disable():
	if (disabled):
		return
	
	disabled = true
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

func _physics_process(delta):
	var dir = Vector2(0,0)
	lv *= 0.99
	translate(delta*lv)
	frame += delta*lv.length_squared()/1000.0
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
	timer.set_wait_time(30.0)
	add_child(timer)
	timer.connect("timeout",self,"_disable")
	timer.start()
	connect("body_entered",self,"_explode")
	connect("area_entered",self,"_explode")
	frames = get_node("Sprite").get_hframes()*get_node("Sprite").get_vframes()
	if (OS.has_feature("web")):
		get_node("BackBufferCopy").queue_free()
