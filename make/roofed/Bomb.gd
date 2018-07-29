extends RigidBody2D

signal boom
signal score
signal life_lost

onready var smoke = preload("res://smoke.tscn")


var bomb_position = Vector2()
var smoke_position = Vector2()

func _ready():
	randomize()
	angular_velocity = rand_range(-PI, PI)
	var s = smoke.instance()
	s.position = position + Vector2(0,5)
	add_child(s)
	
func _on_Bomb_body_entered( body ):
	# contacts reported must be > 0
	# contact monitored must be true
#	print(body.get_name())
	var body_hit = body.get_name()
	bomb_position = self.position
	if body_hit == "TileMap0":
		emit_signal("boom", bomb_position)
#		print("bomb_position =" + str(bomb_position))
		queue_free()
	elif body_hit == "player":
		emit_signal("boom", bomb_position)
		emit_signal("life_lost")
		queue_free()
	else:
		pass	
		
		