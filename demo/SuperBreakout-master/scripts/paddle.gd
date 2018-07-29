extends KinematicBody2D

export (int) var SPEED = 10

var multi_touch = {}

onready var size = $Sprite.texture.get_size() * $Sprite.scale

func _process(delta):
	var slide = Vector2(0, 0)
	for idx in multi_touch:
		var touch = multi_touch[idx]
		if touch["pressed"]:
			if touch["position"].x < get_viewport().size.x / 2:
				slide.x -= SPEED
			else:
				slide.x += SPEED
	if slide.length() > 0:
		move_and_collide(slide)
	pass

func _input(event):
	if event is InputEventScreenTouch:
		multi_touch[event.index] = {
			"pressed": event.pressed,
			"position": event.get_position()
		}
	elif event is InputEventScreenDrag:
		if event.relative.y < -60 and $Ball.visible:
			$Ball.visible = false
			get_parent().spawn_ball()
	pass
