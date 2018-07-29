extends Particles2D

onready var bomb_sound = get_node("bomb_sound")

func _ready():
	bomb_sound.play()
	yield(get_tree().create_timer(2.0), "timeout")
	queue_free()