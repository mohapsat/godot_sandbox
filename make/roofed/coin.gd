extends RigidBody2D

signal score

onready var anim = get_node("sprite/anim")
onready var coin_pickup_sound = get_node("coin_pickup_sound")
#onready var sprite = get_node("sprite")

func _ready():
	anim.play("spin")

	yield(get_tree().create_timer(10.0), "timeout")
	queue_free() # destroy coin in 10 secs
	pass

func _on_coin_body_entered( body ):
	# contacts reported must be > 0
	# contact monitored must be true
#	print(body.get_name())
	var body_hit = body.get_name()
	
	if body_hit == "player":
		coin_pickup_sound.play()
		emit_signal("score")
		# add a lil delay before coin queu free to hear sound
		yield(get_tree().create_timer(0.2), "timeout")
		queue_free()