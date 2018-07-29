extends Node2D
export(PackedScene) var Knife
var score = 0
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()


func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	print("Button works")


func _on_ScoreTimer_timeout():
	score += 1


func _on_MobTimer_timeout():
	$MobSpawn/MobSpawnLocation.set_offset(randi())
	var knife = Knife.instance()
	add_child(knife)
	var direction = $MobSpawn/MobSpawnLocation.rotation + PI/2
	knife.position = $MobSpawn/MobSpawnLocation.position
	knife.rotation = direction
	knife.set_linear_velocity(Vector2(rand_range(knife.MIN_SPEED, knife.MAX_SPEED), 0).rotated(direction))


func _on_Button_pressed():
	$StartTimer.start()

