extends Node2D

var speed = 2000
var direction = 1

onready var sprite = $Sprite
onready var left_axe = $LeftAxe
onready var right_axe = $RightAxe
onready var timer = $Timer

var sprite_height

func _ready():
	sprite_height = sprite.texture.get_height() * scale.y
	set_process(false)
	
func _process(delta):
	position.x += speed * direction * delta
	
func setup_trunk(hasAxe, isRight):
	if hasAxe:
		if isRight:
			left_axe.queue_free()
		else:
			right_axe.queue_free()
	else:
		left_axe.queue_free()
		right_axe.queue_free()

func remove(fromRight):
	if fromRight:
		direction = -1
	else:
		direction = 1
	timer.start()
	set_process(true)

func _on_Timer_timeout():
	queue_free()