extends Camera2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var tween = $Tween

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func newCamerPos(pos,camerZoom,time,transition,tweenEase):
#	print("ell")
	tween.stop_all()
	tween.interpolate_property(self,"position",position,pos,time,transition,tweenEase)
	tween.interpolate_property(self,"zoom",zoom,camerZoom,time,transition,tweenEase)
	tween.start()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
