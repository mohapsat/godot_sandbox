extends KinematicBody2D

onready var sprite = get_node("sprite")
onready var jump_sound = get_node("jump_sound")

const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELARATION = 50
const MAX_SPEED = 500
const JUMP_HEIGHT = -500
const FRICTION = 0.1

var motion = Vector2()
var screensize

func _ready():
	screensize = get_viewport_rect().size
#	print("screen size =" + str(screensize))

func _physics_process(delta):
#	print(position)

	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		motion.x += ACCELARATION
		motion.x = min(motion.x, MAX_SPEED)
		
		sprite.flip_h = false
		sprite.play("walking")
		
		if position.x >= screensize.x:
			position.x = 0.0
			
	elif Input.is_action_pressed("ui_left"):
		motion.x -= ACCELARATION
		motion.x = max(motion.x, -MAX_SPEED)
		
		sprite.flip_h = true
		sprite.play("walking")

		if position.x < 0.0:
			position.x = screensize.x
			
	elif Input.is_action_pressed("ui_down"):
		motion.x = 0
		
		sprite.play("ducking")
	else:
		sprite.play("idle")
#		motion.x = 0
		motion.x = lerp(motion.x, 0, FRICTION) #smooth stop
		# weight in lerp can be used for friction
				
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			jump_sound.play()
			motion.y = JUMP_HEIGHT
	else:
		sprite.play("jumping")

						
	motion = move_and_slide(motion, UP)