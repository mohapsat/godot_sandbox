extends RigidBody2D

export var hp = 300
export var la = 175.0
export var aa = 0.004
export var score = 375
export var size = 2
var frame = 0
var frames = 0
var frame_base = 0
var thrust = 1.0
var strafe = 0.0
var angle = 0.0
var time = 5.0
var delay_missile = 10.0
var delay_shoot = 1.5
var target
var disabled = false

var shot = preload("res://scenes/weapons/es.tscn")
var missile = preload("res://scenes/weapons/em.tscn")
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
	frame += delta*(3*frame_offset/max(abs(frame_offset),1)-150*angular_velocity)
	if (frame<0):
		frame = 0
	elif (frame>frames-1):
		frame = frames-1
	get_node("Sprite").set_frame(round(frame))
	get_node("Engine/Bubbles").set_emitting(thrust>0)
	get_node("Engine/Engine").set_emitting(thrust>0)
	
	time -= delta
	
	if (target!=null && !target.disabled):
		var tpos = target.get_global_position()
		angle = get_angle_to(tpos)
		strafe = clamp(round(global_transform.y.dot(tpos-global_position)/global_position.distance_to(tpos)),-1.0,1.0)
		if (time<=0.0):
			var ang = get_angle_to(target.get_global_position())
			if (global_position.distance_squared_to(target.get_global_position())<800000 && ((ang>PI/4.0 && ang<PI*3.0/4.0) || (ang<-PI/4.0 && ang>-PI*3.0/4.0))):
				var side = "R"
				var ID = 0
				var min_dist = 1000000.0
				if (ang<0):
					side = "L"
				for i in range(1,5):
					var d = get_node("Beam"+side+str(i)).get_global_position().distance_squared_to(target.get_global_position())
					if (d<min_dist):
						min_dist = d
						ID = i
				if (ID>0):
					var si = shot.instance()
					var rot = rotation
					if (side=="R"):
						rot += PI/2.0
					else:
						rot -= PI/2.0
					get_node("Beam"+side+str(ID)+"/Animation").play("prepare")
					time += delay_shoot
					yield(get_node("Beam"+side+str(ID)+"/Animation"),"animation_finished")
					si.set_global_position(get_node("Beam"+side+str(ID)).get_global_position())
					si.set_rotation(rot)
					si.lv = Vector2(1000.0,0.0).rotated(rot)
					get_node("/root/Level").add_child(si)
			else:
				var mi = missile.instance()
				mi.set_global_position(get_node("Missile"+str(randi()%2+1)).get_global_position())
				mi.set_rotation(rotation)
				mi.lv = Vector2(500.0,0.0).rotated(rotation)
				get_node("/root/Level").add_child(mi)
				time += delay_missile
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
	frame_base = round(frames/2)
	frame = frame_base
	if (has_node("/root/Level/Player")):
		target = get_node("/root/Level/Player")
	if (OS.has_feature("web")):
		get_node("BackBufferCopy").queue_free()
