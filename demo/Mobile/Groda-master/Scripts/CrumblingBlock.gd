extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var shaking = false
var isFalling = false
export var shakePow = 3.0
func _ready():
	if contacts_reported == 0:
		contacts_reported = 5
	contact_monitor = true
	#connect("body_entered", self, "hit_block")
	pass

func _process(delta):
#	if isFalling:
		#position += Vector2(0,15)
	
	if shaking:
		get_node("Sprite").position = Vector2(rand_range(0,shakePow)-shakePow/2,rand_range(0,shakePow)-shakePow/2)
	
	
	pass
func _integrate_forces(state):
	if isFalling:
		var xform = state.get_transform()
		xform.origin.y += 25
#		xform.origin = position
		state.set_transform(xform)
	pass
func hit_block(body):
	pass


func _on_CrumblingBlock_body_entered( body ):
	pass # replace with function body


func _on_CrumblingBlock_body_shape_entered( body_id, body, body_shape, local_shape ):
	#print("poo")
	shaking = true
	get_node("Timer").start()
	pass # replace with function body


func _on_Timer_timeout():
	get_node("CollisionShape2D").disabled = true
	isFalling = true
	shaking = false
	
	
	get_node("Timer").stop()
	pass # replace with function body
