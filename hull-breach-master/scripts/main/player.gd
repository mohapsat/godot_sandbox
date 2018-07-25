extends RigidBody2D

export var gun_pos = Vector2(0,0)
export var engine_pos = Vector2(0,0)

var hp = 5
var hp_max = 5
var sp = 1
var sp_max = 5
var weapon = 0
var upgrade = 0
var la = 0
var aa = 0
var delay_reload = 15.0
var delay = 0.25
var time_reload = 30.0
var frame = 0
var frames = 0
var frame_base = 0
var max_rot = 50
var shooting = 0.0
var time = 0.5
var invulnerable = 0.0
var mouse = true
var disabled = false

var flash = [preload("res://scenes/particles/flash_mg.tscn"),preload("res://scenes/particles/flash_bl.tscn"),preload("res://scenes/particles/flash_pb.tscn")]
var shot = [preload("res://scenes/weapons/mg.tscn"),preload("res://scenes/weapons/bl.tscn"),preload("res://scenes/weapons/pb.tscn")]
var special = [preload("res://scenes/weapons/mi.tscn"),preload("res://scenes/weapons/mn.tscn"),preload("res://scenes/weapons/sh.tscn")]
var sounds_explosion = [preload("res://sounds/explosions/explosion01.wav"),preload("res://sounds/explosions/explosion02.wav"),preload("res://sounds/explosions/explosion03.wav"),preload("res://sounds/explosions/explosion04.wav"),preload("res://sounds/explosions/explosion05.wav"),preload("res://sounds/explosions/explosion06.wav"),preload("res://sounds/explosions/explosion07.wav"),preload("res://sounds/explosions/explosion08.wav"),preload("res://sounds/explosions/explosion09.wav")]


func _disable():
	if (disabled):
		return
	
	var timer = Timer.new()
	disabled = true
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)
	get_node("Animation").play("explode")
	get_node("SoundExplosion").set_stream(sounds_explosion[randi()%(sounds_explosion.size())])
	get_node("SoundExplosion").play()
	timer.set_one_shot(true)
	timer.set_wait_time(4.0)
	get_node("/root/Level").add_child(timer)
	timer.connect("timeout",get_node("/root/Menu"),"_game_over",[get_node("/root/Level").score])
	timer.start()

func damaged(dmg=1,by_player=false):
	hp -= dmg
	if (hp<=0):
		_disable()
	else:
		get_node("Animation").play("hit")

func shoot():
	if (disabled):
		return
	if (weapon==0):
		for i in range(2):
			var si = shot[weapon].instance()
			var fi = flash[weapon].instance()
			si.set_global_position(get_node("Gun"+str(i+1)).get_global_position())
			si.lv = Vector2(2000.0,0.0).rotated(rotation)+linear_velocity
			si.set_rotation(rotation)
			get_parent().add_child(si)
			get_node("Gun"+str(i+1)).add_child(fi)
			get_node("Gun"+str(i+1)+"/Sound").play()
	elif (weapon==1):
		for i in range(2):
			var si = shot[weapon].instance()
			var fi = flash[weapon].instance()
			si.set_global_position(get_node("Gun"+str(i+1)).get_global_position())
			si.lv = Vector2(3000.0,0.0).rotated(rotation)+linear_velocity
			si.set_rotation(rotation)
			get_parent().add_child(si)
			get_node("Gun"+str(i+1)).add_child(fi)
			get_node("Gun"+str(i+1)+"/Sound").play()
	elif (weapon==2):
		for i in range(2):
			var si = shot[weapon].instance()
			var fi = flash[weapon].instance()
			si.set_global_position(get_node("Gun"+str(i+1)).get_global_position())
			si.lv = Vector2(1000.0,0.0).rotated(rotation)+linear_velocity
			si.set_rotation(rotation)
			get_parent().add_child(si)
			get_node("Gun"+str(i+1)).add_child(fi)
			get_node("Gun"+str(i+1)+"/Sound").play()
	shooting = min(max(shooting,0.0)+5*delay,1.0)
	time += delay

func special():
	if (disabled):
		return
	if (sp<=0):
		UI.get_node("SoundNoAmmo").play()
		return
	if (weapon==0):
		for i in range(2):
			var si = special[weapon].instance()
			var rot = get_global_mouse_position().angle_to_point(get_node("Gun"+str(i+1)).get_global_position())
			si.set_global_position(get_node("Gun"+str(i+1)).get_global_position())
			si.lv = Vector2(500.0,0.0).rotated(rot)+linear_velocity
			si.set_rotation(rot)
			get_parent().add_child(si)
	elif (weapon==1):
		var si = special[weapon].instance()
		si.set_global_position(global_position)
		si.lv = linear_velocity
		get_parent().add_child(si)
	elif (weapon==2):
		var si = special[weapon].instance()
		add_child(si)
		
	sp -= 1


func _process(delta):
	var thrust = Input.is_action_pressed("thrust")
	var frame_offset = frame_base-frame
	
	if (time>0.0):
		time -= delta
	elif (Input.is_action_pressed("shoot")):
		shoot()
	time_reload -= delta
	if (time_reload<=0.0):
		sp += 1
		if (sp>sp_max):
			sp = sp_max
		time_reload += delay_reload*(10+get_node("/root/Level").difficulty)/10.0
	shooting -= delta*5.0
	
	frame += delta*(10*frame_offset/max(abs(frame_offset),1)-5*angular_velocity)
	if (frame<0):
		frame = 0
	elif (frame>frames-1):
		frame = frames-1
	for i in range(2):
		get_node("Gun"+str(i+1)).set_position(Vector2(gun_pos.x,2.0*(i-0.5)*gun_pos.y*cos(deg2rad(2.0*max_rot*(frame_base-round(frame))/frames))))
	for i in range(2):
		get_node("Engine"+str(i+1)).set_position(Vector2(engine_pos.x,2.0*(i-0.5)*engine_pos.y*cos(deg2rad(2.0*max_rot*(frame_base-round(frame))/frames))))
	get_node("Sprite").set_frame(round(frame))
	for i in range(1,3):
		get_node("Engine"+str(i)+"/Bubbles").set_emitting(thrust)
		get_node("Engine"+str(i)+"/Engine").set_emitting(thrust)

func _physics_process(delta):
	var thrust = float(Input.is_action_pressed("thrust"))-0.25*float(Input.is_action_pressed("reverse_thrust"))
	var strafe = float(Input.is_action_pressed("strafe_right"))-float(Input.is_action_pressed("strafe_left"))
	var angle = float(Input.is_action_pressed("rotate_right"))-float(Input.is_action_pressed("rotate_left"))
	if (mouse):
		if (angle!=0.0):
			mouse = false
		angle = get_angle_to(get_global_mouse_position())
	
	if (thrust!=0 || strafe!=0):
		apply_impulse(global_position,la*Vector2(thrust,0.2*strafe).rotated(rotation))
	
	angle -= 0.1*angular_velocity
	angular_velocity += aa*angle/max(abs(angle),1)

func _input(event):
	if (disabled):
		return
	if (event is InputEventKey || event is InputEventMouseButton):
		if (event.is_action_pressed("special")):
			special()
	elif (event is InputEventMouseMotion):
		mouse = true

func _collide(body):
	damaged(1)
	if (body.has_method("damaged")):
		body.damaged(20,true)

func _ready():
	var mat = get_node("Sprite").get_material().duplicate()
	get_node("Sprite").set_material(mat)
	set_process(true)
	set_process_input(true)
	connect("body_entered",self,"_collide")
	frames = get_node("Sprite").get_hframes()*get_node("Sprite").get_vframes()
	frame_base = round(frames/2)
	frame = frame_base
	if (OS.has_feature("web")):
		get_node("BackBufferCopy").queue_free()
