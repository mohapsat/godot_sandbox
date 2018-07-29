extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var pos = Vector2()
export var camerZoom = Vector2(1,1)
export var time = 1.0
export(int, "LINEAR", "SINE", "QUINT","QUART","QUAD","EXPO","ELASTIC","CUBIC","CIRC","BOUNCE","BACK") var transition = 0
export(int, "IN", "OUT", "IN_OUT","OUT_IN") var tweenEase = 0
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("body_entered", self, "_on_CamArea_body_entered")
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_CamArea_body_entered( body ):
	if body.name == "Frog":
		get_tree().call_group("LevelCamera","newCamerPos",pos,camerZoom,time,transition+1,tweenEase+1)
	pass # replace with function body
