extends Sprite

#var velocity = Vector2(400,350) # randomize velocity
var velocity
var screensize
var sprite_pos
var extent = 50 # this is simple way to get boundaries of the sprite
var sprite_scale

func _ready():
	randomize() # since rand_range produces same vals each time
	
	velocity = Vector2(rand_range(100,300),0).rotated(rand_range(0, 2*PI))
	screensize = get_viewport_rect().size
	sprite_pos = screensize / 2 # will get sprite to center
#	sprite_scale = get_scale()
#	set_scale(sprite_scale/2)
#	print("scale = " + str(sprite_scale))

func _process(delta):
	
	# position and rotation are member vars in Node2D,
	# see classes documentation for more...
	
	sprite_pos += velocity * delta
	position = sprite_pos
	
	if (sprite_pos.x + extent) >= screensize.x or (sprite_pos.x - extent) <= 0:
		velocity.x *= -1
	if (sprite_pos.y + extent) >= screensize.y or (sprite_pos.y - extent) <= 0:
		velocity.y *= -1
	
	rotation += PI * delta # PI is equivalent to 180 deg in radians
	# can be randomized as well
#	print(position)
	
# [SELF] instance child nodes on timer
	if Input.is_action_just_pressed("ui_select"): #space
		print("Nice, You pressed the space bar!")

func _on_spawn_timer_timeout():
		pass
#		print("spawning child")
#		$spawn_timer.stop()
# No need to start and stop timer if One Shot is checked	
