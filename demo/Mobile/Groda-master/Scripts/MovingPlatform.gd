extends Path2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var speed = 100
var otherParent

onready var follow = $PathFollow2D

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _physics_process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	follow.offset += speed *delta
	pass


func _on_Area2D_body_entered( body ):
#	call_deferred("reparent",body)
#	otherParent = body.get_parent()
	#otherParent.remove_child(body)
	#get_tree().root.remove_child(body)
	#add_child(body)
	pass # replace with function body


func _on_Area2D_body_exited( body ):
	#remove_child(body)
	#otherParent.add_child(body)
	pass # replace with function body
	
func reparent(node):
  node.get_parent().remove_child(node) # error here  
  add_child(node) 