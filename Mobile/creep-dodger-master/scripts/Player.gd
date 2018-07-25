extends Area2D

const MARGIN = 5 # pixels gap between player and boundary

signal hit
export (int) var speed # pixels/sec

onready var animated_sprite = $AnimatedSprite
onready var collision_shape = $CollisionShape2D

var screen_size
var player_size

func _ready():
	screen_size = get_viewport_rect().size
	player_size = animated_sprite.frames.get_frame("right", 0).get_size() * scale
	hide()

func _process(delta):
	# determine velocity orientation
	var velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	# calculate velocity in speed units
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		animated_sprite.play()
		$Trail.emitting = true
	else:
		animated_sprite.stop()
		$Trail.emitting = false
	
	# select correct animation sequence
	if velocity.x != 0:
		animated_sprite.animation = "right"
		animated_sprite.flip_v = false
		animated_sprite.flip_h = velocity.x < 0
		player_size = animated_sprite.frames.get_frame("right", 0).get_size() * scale
	elif velocity.y != 0:
		animated_sprite.animation = "up"
		animated_sprite.flip_v = velocity.y > 0
		player_size = animated_sprite.frames.get_frame("up", 0).get_size() * scale
		
	# calculate position
	position += velocity * delta
	position.x = clamp(position.x, player_size.x/2 + MARGIN , screen_size.x - (player_size.x/2 + MARGIN))
	position.y = clamp(position.y, player_size.y/2 + MARGIN, screen_size.y - (player_size.y/2 + MARGIN))
	

func _on_Player_body_entered(body):
	hide()
	emit_signal("hit")
	collision_shape.disabled = true	

func start(start_position):
	position = start_position
	show()
	collision_shape.disabled = false
