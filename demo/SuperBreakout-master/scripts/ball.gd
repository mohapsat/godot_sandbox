extends RigidBody2D

export (int) var ACCELERATION = 3
export (int) var MAX_SPEED = 350

func _physics_process(delta):
	delta *= 100
	var bodies = get_colliding_bodies()
	for body in bodies:
		if "Paddle" in body.name:
			var speed = get_linear_velocity().length()
			var direction = get_position() - body.get_node("Anchor").get_global_position()
			var velocity = direction.normalized() * min(speed + ACCELERATION * delta, MAX_SPEED * delta)
			set_linear_velocity(velocity)
	pass
