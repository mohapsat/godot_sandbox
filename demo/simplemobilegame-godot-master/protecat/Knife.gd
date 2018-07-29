
extends RigidBody2D
export (int) var MIN_SPEED # minimum speed range
export (int) var MAX_SPEED # maximum speed range
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Button_pressed():
	queue_free()
