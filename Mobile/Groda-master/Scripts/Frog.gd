extends RigidBody2D


var startMousePos
var endMousePos
var gravity = 98
var charging = false
var inWater = false
var ground = null
var groundPrevPos =Vector2()
var conveyorMovement = 0
var movingPlaformMovement = Vector2(2,0)

export var maxDistance = 300
export var jumpPower = 1.5
export var rotateMod= 1500
export var rotateOffset = 0.1
export var waterDamp = 3.0
export var waterGravity = -1

onready var on_ground = $OnGround
onready var anim = $Sprite/AnimationPlayer
onready var sprite = $Sprite

func _ready():
	anim.play("InAir")
	pass

func _input(event):
	
	if event.is_action_pressed("Jump") and on_ground.is_colliding():
		startMousePos = get_global_mouse_position()
		charging = true
		anim.play("Charge")
		pass
	if event.is_action_released("Jump") and charging:
		endMousePos = get_global_mouse_position()
		set_axis_velocity(getImpulse())
		startMousePos = null
		endMousePos = null
		charging = false
		anim.play("Jump")
		update()
		pass
	pass

func _integrate_forces(state):
	if not ground == null:
		var globalPos = ground.global_position
		movingPlaformMovement = globalPos-groundPrevPos
		groundPrevPos = globalPos
	
	
	var xform = state.get_transform()
	xform.origin.x += conveyorMovement
	xform.origin += movingPlaformMovement
	state.set_transform(xform)
	pass

func _physics_process(delta):
	if on_ground.is_colliding():
		
		if not ground == on_ground.get_collider():
			ground = on_ground.get_collider()
			groundPrevPos = ground.global_position
			#gravity_scale = 0
			pass
	#	else:
	else:
		ground = null
		groundPrevPos = Vector2()


func _process(delta):
	
	if on_ground.is_colliding():
		var coll =on_ground.get_collider()
		if not coll.is_a_parent_of(self):
			
			pass
	
	# Apply sprite flip
	if Input.is_action_pressed("Jump") and charging:
		update()
		sprite.flip_h = getImpulse().x > 0
	else:
		if abs(linear_velocity.x) > 2:
			sprite.flip_h = linear_velocity.x > 2
	
	sprite.rotation = spriteRotation()
	
	# if landing change to Land animation
	if on_ground.is_colliding() and not inWater:
		if get_node("Sprite").frame == 3:
			anim.play("Land")
		pass
	pass

func _draw():
	if charging:
		var dotAmount = 11
		for t in range(1, dotAmount):
			
			draw_circle(getFuturePos(getImpulse(),(t/14.0))
			,10*(dotAmount-t)/dotAmount,Color(1,0,0))
			pass
	pass

func spriteRotation():
	if inWater:
		if sprite.flip_h:
			return rotateOffset
		else:
			return -rotateOffset
		#-rotateOffset
	
	
	if on_ground.is_colliding():
		return 0
	else:
		if sprite.flip_h:
			return linear_velocity.y / rotateMod+rotateOffset
		else:
			return -linear_velocity.y / rotateMod-rotateOffset
	

func getFuturePos(impulseVec,time):
	var final_pos = Vector2()
	final_pos.x = impulseVec.x*time
	final_pos.y = impulseVec.y*time+(gravity*gravity_scale*time*time/2)
	return final_pos
	pass

func toNumber(n):
	var numb = 0.0
	for i in range (1,floor(n)):
		numb += i
	#if (n%1.0) >(0.0):
	numb += n
	return numb

func getImpulse():
	var aim = Vector2()
	aim= startMousePos-get_global_mouse_position()
	if Vector2().distance_to(aim) > maxDistance:
		aim = aim.normalized()*maxDistance
	
	return aim*jumpPower
	pass

func _on_AnimationPlayer_animation_finished( anim_name ):
	if anim_name == "Land":
		anim.play("idle")
	if anim_name == "Jump":
		anim.play("InAir")
	pass # replace with function body
	

func start_swimming():
	inWater =true
	gravity_scale = waterGravity
	linear_damp = waterDamp
	anim.play("InAir")
	pass

func end_swimming():
	inWater = false
	gravity_scale = 30
	linear_damp = -1
#	anim.play("InAir")
	pass

func kill():
	get_tree().reload_current_scene()
	pass
