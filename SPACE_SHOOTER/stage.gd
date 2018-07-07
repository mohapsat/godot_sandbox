extends Node2D

var is_game_over = false
var asteroid = preload("res://asteroid.tscn")

const SCREEN_WIDTH = 320
const SCREEN_HEIGHT = 180

signal score
var score_var = 0

func _ready():
	$player.connect('destroyed',self,'_on_player_destroyed')
	#To create periodically spawning asteroids, we first connect the timeout signal of the stage scene’s “spawn_timer” node to our stage script. When the timer timeouts, we spawn an instance of the asteroid scene at a random location outside our screen.
	$spawn_timer.connect('timeout',self,'on_spawn_timer_timeout')
	
	

func _input(event):
	
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
	if is_game_over and Input.is_key_pressed(KEY_ENTER):
		# restart the game using change_scene
		get_tree().change_scene("res://stage.tscn")
		
	
func _on_player_destroyed():
	$"ui/retry".show()
	is_game_over = true
	

func _on_spawn_timer_timeout():
	
	var asteroid_instance = asteroid.instance()
	asteroid_instance.position -= Vector2(SCREEN_WIDTH + 8
											, rand_range(10, SCREEN_HEIGHT))
	add_child(asteroid_instance)
#	print(asteroid_instance_position)
	asteroid_instance.connect("score",self,"_on_player_score")
	var asteroids = get_child_count()
	print(asteroids)
	
func _on_player_score():
	score_var += 1
	$"ui/score".text = "Score: " + str(score_var)
	
	
	
	