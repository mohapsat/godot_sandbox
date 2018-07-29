extends RigidBody2D

export var hp = 11
export var la = 40.0
export var aa = 0.15
export var score = 12
export var size = 1.5
export var engine_pos = Vector2(0,0)
var frame = 0
var frames = 0
var frame_base = 0
var max_rot = 30
var thrust = 1.0
var strafe = 0.0
var angle = 0.0
var time = 0.0
var time_shoot = 5.0
var delay = 7.5
var shooting = false
var target
var disabled = false

var shot = preload("res://scenes/weapons/es.tscn")
var sounds_explosion = [preload("res://sounds/explosions/explosion01.wav"),preload("res://sounds/explosions/explosion02.wav"),preload("res://sounds/explosions/explosion03.wav"),preload("res://sounds/explosions/explosion04.wav"),preload("res://sounds/explosions/explosion05.wav"),preload("res://sounds/explosions/explosion06.wav"),preload("res://sounds/explosions/explosion07.wav"),preload("res://sounds/explosions/explosion08.wav"),preload("res://sounds/explosions/explosion09.wav")]


func _disable():
	if (disabled):
		return
	
	disabled = true
	set_process(false)
	get_node("/root/Level").enemy.erase(self)
	set_collision_layer(0)
	set_collision_mask(0)
	get_node("Animation").play("explode")
	get_node("SoundExplosion").set_stream(sounds_explosion[randi()%(sounds_explosion.size())])
	get_node("SoundExplosion").play()

func damaged(dmg=1,by_player=false):
	hp -= dmg
	if (hp<=0):
		_disable()
		if (by_player):
			get_node("/root/Level").score += score
	else:
		get_node("Animation").play("hit")

func _process(delta):
	var frame_offset = frame_base-frame
	frame += delta*(6*frame_offset/max(abs(frame_offset),1)-5*angular_velocity)
	if (frame<0):
		frame = 0
	elif (frame>frames-1):
		frame = frames-1
	for i in range(2):
		get_node("Engine"+str(i+1)).set_position(Vector2(engine_pos.x,2.0*(i-0.5)*engine_pos.y*cos(deg2rad(2.0*max_rot*(frame_base-round(frame))/frames))))
	get_node("Sprite").set_frame(round(frame))
	for i in range(1,3):
		get_node("Engine"+str(i)+"/Bubbles").set_emitting(thrust>0)
		get_node("Engine"+str(i)+"/Engine").set_emitting(thrust>0)
	
	time += delta
	time_shoot -= delta
	
	if (target!=null && !target.disabled):
		var tpos = target.get_global_position()+Vector2(256.0*clamp(time_shoot/4.0,0.0,1.0),0.0).rotated(0.1*time)
		var reverse = 1.0-2.0*float(global_position.distance_squared_to(target.get_global_position())<40000)
		angle = get_angle_to(tpos)
		thrust = clamp(reverse*stepify(global_transform.x.dot(tpos-global_position)/global_position.distance_to(tpos),0.25),-0.25,1.0)
		strafe = clamp(reverse*round(global_transform.y.dot(tpos-global_position)/global_position.distance_to(tpos)),-1.0,1.0)
		if (time_shoot<=0.0 && !shooting):
			if (global_position.distance_squared_to(tpos)>200000 || angle>PI/4.0):
				time_shoot += 1.0
				return
			var si = shot.instance()
			get_node("Beam/Animation").play("prepare")
			shooting = true
			yield(get_node("Beam/Animation"),"animation_finished")
			if (disabled):
				return
			si.set_global_position(get_node("Beam").get_global_position())
			si.set_rotation(rotation)
			si.lv = Vector2(1000.0,0.0).rotated(rotation)
			get_node("/root/Level").add_child(si)
			get_node("SoundGun").play()
			shooting = false
			time_shoot += delay
	else:
		target = null
		angle = 0.0
		thrust = 1.0
		strafe = 0.0

func _physics_process(delta):
	if (thrust!=0 || strafe!=0):
		apply_impulse(global_position,la*Vector2(thrust,0.2*strafe).rotated(rotation))
	
	angle -= 0.1*angular_velocity
	angular_velocity += aa*angle/max(abs(angle),1)

func _collide(body):
	damaged(20)
	if (body.get_name()=="Player"):
		get_node("/root/Level").score += score

func _ready():
	var mat = get_node("Sprite").get_material().duplicate()
	get_node("Sprite").set_material(mat)
	set_process(true)
	connect("body_entered",self,"_collide")
	get_node("/root/Level").enemy.push_back(self)
	frames = get_node("Sprite").get_hframes()*get_node("Sprite").get_vframes()
	if (has_node("/root/Level/Player")):
		target = get_node("/root/Level/Player")
	if (OS.has_feature("web")):
		get_node("BackBufferCopy").queue_free()
