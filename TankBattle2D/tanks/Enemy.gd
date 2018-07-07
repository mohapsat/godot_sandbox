extends "res://tanks/Tank.gd"

# again, just need to override the control method

# not all enemy tanks may be attached to a path2d
onready var parent = get_parent()

var target = null

export (float) var turret_speed
export (int) var detect_radius

# take the detect radius value and set to collisionShape2D radius at runtime
# do this in ready to take effect at runtime

func _ready():
	$"DetectRadius-Area2D/CollisionShape2D".shape.radius = detect_radius
	

func control(delta):
	if parent is PathFollow2D:
		# to path follow, set offset to parent
		parent.set_offset(parent.get_offset() + speed * delta)
		# if player blocks enemy tank, it loses offset.
		# to fix, set position 0,0 relative to parent
		position = Vector2()
	else:
		# other movement code, to be added later		
		pass

# once body is in are, we need to aim at it
# use process function for this
func _process(delta):
	
	if target: # if there is a target
		# aim, first get the dir to the target
		# target direction is a vector, targets position - our position
		var target_direction = (target.global_position - global_position).normalized()
		# get our (enemy) turret's current direction
		# unit vector, rotated by turrets global rotation
		#print("target_direction = " + str(target_direction))
		
		var current_direction = Vector2(1,0).rotated($Turret.global_rotation)
		# set the angle for the turrent, using above directions, will return a vector.. we need its angle
		
		#print("current_direction = " + str(current_direction))
		
		#print ("Target Present = " + str(target.name))
		
		$Turret.global_rotation = current_direction.linear_interpolate(target_direction, turret_speed * delta).angle()
		

func _on_DetectRadiusArea2D_body_entered(body):
	if body.name == "Player":
		target = body


func _on_DetectRadiusArea2D_body_exited(body):
	# could be any body exiting
	if body == target:
		target = null # drop target if it leaves the area
