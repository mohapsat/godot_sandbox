extends KinematicBody2D

onready var sprite = get_node("sprite")

const UP = Vector2(0, -1)
const GRAVITY = 20
const SPEED = 400
const JUMP_HEIGHT = -500

var motion = Vector2()

func _physics_process(delta):

	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		motion.x = SPEED
		sprite.flip_h = false
		sprite.play("running")
		
	elif Input.is_action_pressed("ui_left"):
		motion.x = -SPEED
		sprite.flip_h = true
		sprite.play("running")
	else:
		motion.x = 0
		sprite.play("idle")
		
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			motion.y = JUMP_HEIGHT
	else:
		sprite.play("jump")
			
	motion = move_and_slide(motion, UP)