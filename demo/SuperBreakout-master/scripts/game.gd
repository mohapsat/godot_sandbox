extends Node2D

const Ball = preload("res://scenes/ball.tscn")

export (int) var SPEED = 500

var ball

func spawn_ball():
	ball = Ball.instance()
	add_child(ball)
	ball.set_position($Paddle.get_position() + Vector2(0, -50))
	ball.set_linear_velocity(Vector2(0, -SPEED))
	pass
