extends KinematicBody2D

onready var sprite = get_node("sprite")

const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELARATION = 50
const MAX_SPEED = 400
const JUMP_HEIGHT = -500
const FRICTION = 0.1

var motion = Vector2()

func _physics_process(delta):

	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		motion.x += ACCELARATION
		motion.x = min(motion.x, MAX_SPEED)
					
		sprite.flip_h = false
		sprite.play("running")
		
	elif Input.is_action_pressed("ui_left"):
		motion.x -= ACCELARATION
		motion.x = max(motion.x, -MAX_SPEED)
		
		sprite.flip_h = true
		sprite.play("running")
	else:
		sprite.play("idle")
#		motion.x = 0
		motion.x = lerp(motion.x, 0, FRICTION) #smooth stop
		# weight in lerp can be used for friction
				
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			motion.y = JUMP_HEIGHT
	else:
		if motion.y < 0:
			sprite.play("jump_up")
		else:
			sprite.play("jump_fall")
			
	motion = move_and_slide(motion, UP)