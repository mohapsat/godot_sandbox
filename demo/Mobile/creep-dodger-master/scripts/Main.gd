extends Node

export (PackedScene) var mob

onready var mob_timer = $MobTimer
onready var score_timer = $ScoreTimer
onready var start_timer = $StartTimer
onready var hud = $HUD

onready var player = $Player
onready var start_position = $StartPosition
onready var mob_spawn_location = $MobPath/MobSpawnLocation

var score

func _ready():
	randomize()

func game_over():
	score_timer.stop()
	mob_timer.stop()
	hud.show_game_over()
	$Music.stop()
	$DeathSound.play()
	
func new_game():
	score = 0
	player.start(start_position.position)
	start_timer.start()
	hud.update_score(score)
	hud.show_message("Get Ready!")
	$Music.play()
	
func _on_StartTimer_timeout():
	mob_timer.start()
	score_timer.start()

func _on_ScoreTimer_timeout():
	score += 1
	hud.update_score(score)

func _on_MobTimer_timeout():
	var new_mob = mob.instance()
	mob_spawn_location.set_offset(randi()) 
	new_mob.position = mob_spawn_location.position
	var direction = mob_spawn_location.rotation + PI/2
	direction += rand_range(-PI/4, PI/4)
	new_mob.rotation = direction
	new_mob.set_linear_velocity(Vector2(rand_range(new_mob.min_speed, new_mob.max_speed), 0).rotated(direction))
	add_child(new_mob)
	
