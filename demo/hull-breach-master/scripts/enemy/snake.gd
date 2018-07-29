extends RigidBody2D

export var hp = 4
export var la = 17.5
export var aa = 0.15
export var score = 2
export var size = 1
var frame = 0
var frames = 0
var strafe = 0.0
var angle = 0.0
var target
var disabled = false

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
	frame -= delta*5*angular_velocity
	if (frame<=-0.5):
		frame += frames
	elif (frame>=frames-0.5):
		frame -= frames
	get_node("Sprite").set_frame(round(frame))
	
	if (has_node("PinJoint")):
		if (!has_node(get_node("PinJoint").get_node_b()) || get_node(get_node("PinJoint").get_node_b()).disabled):
			get_node("PinJoint").queue_free()
		return
	if (target!=null && !target.disabled):
		var tpos = target.get_global_position()
		angle = get_angle_to(tpos)
		strafe = clamp(round(global_transform.y.dot(tpos-global_position)/global_position.distance_to(tpos)),-1.0,1.0)
	else:
		target = null
		angle = 0.0
		strafe = 0.0

func _physics_process(delta):
	if (has_node("PinJoint")):
		return
	
	apply_impulse(global_position,la*Vector2(1.0,0.2*strafe).rotated(rotation))
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
	if (get_node("PinJoint").get_node_b()==""):
		get_node("PinJoint").queue_free()
