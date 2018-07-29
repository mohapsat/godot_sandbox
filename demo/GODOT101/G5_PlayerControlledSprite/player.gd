extends Area2D

export var speed = 400

var screensize
var velocity = Vector2()


func _ready():
	
	screensize = get_viewport_rect().size

func _process(delta):

	var input_dir = Vector2()

	if Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1.0
	if Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1.0
	
	# Move our player to input direction
	position += (speed * delta) * input_dir
	
	# Check if we moved past the screen, if so just move us back
	if position.x < 0.0:
		position.x = 0.0
	elif position.x > screensize.x:
		position.x = screensize.x
	if position.y < 0.0:
		position.y = 0.0
	elif position.y > screensize.y:
		position.y = screensize.y
