extends RigidBody2D

export (int) var min_speed # minimum speed range
export (int) var max_speed # maximum speed range

onready var animated_sprite = $AnimatedSprite

var mob_types = ["walk", "swim", "fly"]

func _ready():
	animated_sprite.animation = mob_types[randi() % mob_types.size()]

func _on_Visibility_screen_exited():
	#kill mob as sson as it leaves the screen
	queue_free()
