extends StaticBody2D

var frogFriction = 0.8
var movingObject =null
export var speed = 30

onready var sprite = $Sprite
var currFrame = 0.0
func _ready():
	get_node("Area2D").gravity = -speed
	pass

func _process(delta):
	# TO FIX MAKE CONVEYOR BELT NOT SLIDING
	if not movingObject == null:
		if movingObject.linear_velocity.x > -speed:
			pass
		
	
	currFrame = currFrame + delta*speed
	if sprite.vframes*sprite.hframes < currFrame:
		currFrame = 0
	#currFrame = currFrame % (sprite.vframes*sprite.hframes*1.0)
	
	sprite.frame = floor(currFrame)
	pass


func _on_Area2D_body_entered( body ):
	if body.name == "Frog":
		movingObject = body
		body.conveyorMovement = -speed/60.0
		
		#frogFriction = body.friction
		#body.friction = 1
		#body.linear_damp = 44
	#	body.linear_velocity.x = -speed
	pass # replace with function body


func _on_Area2D_body_exited( body ):
	if body.name == "Frog":
		movingObject = null
		body.conveyorMovement = 0
		#body.linear_damp = -1
		#body.friction = frogFriction
	pass # replace with function body
