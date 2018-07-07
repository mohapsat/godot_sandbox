extends "res://tanks/Tank.gd"

# for player we just need to override the
# control function and have it do its own thing.

func control(delta):

	# make sure turret is always looking at mouse
	$Turret.look_at(get_global_mouse_position())
	var rotation_dir = 0 # temp var to get rotation, by adding or sub 1
	
	if Input.is_action_pressed('turn_right'):
		rotation_dir += 1
	if Input.is_action_pressed('turn_left'):
		rotation_dir -= 1
	
	# set actual rotation of the body
	rotation += rotation_speed * rotation_dir * delta
	velocity = Vector2() # set to 0
		
	if Input.is_action_pressed('forward'):
		# we move with velocity equal to the speed in the direction
		# of rotation
		velocity = Vector2(speed,0).rotated(rotation)
		
	if Input.is_action_pressed('back'):
		# negative speed
		# go with half speed backwards
		velocity = Vector2(-speed,0).rotated(rotation)
		velocity = velocity /2
		
	if Input.is_action_pressed('click'):
		shoot() # handled in the map script

func _on_Tank_shoot():
	shoot()
