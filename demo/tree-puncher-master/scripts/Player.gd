extends Node2D

onready var animation = $Animation

var game
var center_x
var player_center_offset

func _ready():
	game = get_parent()
	center_x = get_viewport_rect().size.x / 2
	player_center_offset = abs(position.x - center_x)
	connect("area_entered", self, "_on_area_entered")
	
func _on_area_entered(area):
	if area.is_in_group("Axes"):
		game.die()

	
func _input(event):
	var from_right
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.is_pressed():
		if event.position.x < center_x:
			position.x = center_x - player_center_offset
			scale.x = -abs(scale.x)
			game.punch_tree(false)
		else:
			position.x = center_x + player_center_offset
			scale.x = abs(scale.x)
			game.punch_tree(true)
			
		animation.play("punch")	
