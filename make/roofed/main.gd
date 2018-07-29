extends Node


onready var player = get_node("player")
onready var stage_timer_label = get_node("stage_timer_label")
onready var stage_label = get_node("stage_label")
onready var life_label = get_node("life_label")
onready var score_label = get_node("score_label")
onready var game_over_label = get_node("game_over_label")
onready var floor_node = get_node("floor") # floor is a reserved keyword

onready var stage_timer = get_node("stage_timer")
onready var bomb_drop_timer = get_node("bomb_drop_timer")
onready var coin_drop_timer = get_node("coin_drop_timer")

onready var game_over_sound = get_node("game_over_sound")

onready var coin = preload("res://coin.tscn")
onready var bomb = preload("res://Bomb.tscn")
onready var bomb_explosion = preload("res://bomb_explosion.tscn")

var ready_to_drop_coin = true
var ready_to_drop_bomb = true
var is_stage_active = true
var stage = 1
var score = 0
var screensize
var life_left = 3


#export (PackedScene) var bomb_explosion

func _ready():
	
	screensize = get_viewport().size
	
	stage_label.text = "STAGE " + str(stage) 
	stage_timer_label.text = str(stage_timer.time_left)
	stage_timer.start()

	score_label.text = "SCORE " + str(score)
	life_label.text = "LIVES " + str(life_left)
	game_over_label.hide()
	
	
#func _input(event):
#	# If the escape key is pressed we quit the game to desktop
#	if Input.is_key_pressed(KEY_ESCAPE):
#		get_tree().quit()
#
#	# If the game is over and we press escape we restart the stage
#	if life_left <= 0 and Input.is_key_pressed(KEY_ENTER):
#		get_tree().change_scene("res:///main.tscn")

	
func _physics_process(delta):
	
	game_over_label.hide()
	
	if life_left <= 0 and Input.is_key_pressed(KEY_ENTER):
		get_tree().change_scene("res:///main.tscn")



	if life_left > 0:
		stage_timer_label.text = str(int(stage_timer.get_time_left()))
	else:
		stage_timer_label.text = "0"
		life_label.text = "BOMBED!"
		stage_timer.stop()
		player.hide()
		game_over_label.show()

		
		
	
	if life_left > 0 and is_stage_active and ready_to_drop_coin:
		ready_to_drop_coin = false
		randomize()
		var c = coin.instance()
		c.position = Vector2(rand_range(0, screensize.x),-30) # make it rain coins
		add_child(c)
		c.connect("score", self, "score_player_collects_coin")
		coin_drop_timer.start()
	
	if life_left > 0 and is_stage_active and ready_to_drop_bomb:
		ready_to_drop_bomb = false
		randomize()
		var b = bomb.instance()
		b.position = Vector2(rand_range(0, screensize.x),-30) # make it rain
		add_child(b)
		
		b.connect("boom", self, "explode")
		b.connect("life_lost", self, "player_life_lost")
		
#		if int(stage_timer.get_time_left()) <= 5:
#			bomb_drop_timer.wait_time = 0.1 # drop multiple bombs 
	
		bomb_drop_timer.start()
		
#	pass

func _on_stage_timer_timeout():
	# increment stage number and  update label
	is_stage_active = false
	stage += 1
	stage_label.text = "INCOMING!!!"
	# can add a stage transition cool off time, to give time to prepare
	stage_label.text = "STAGE " + str(stage) 
	stage_timer.start()
	is_stage_active = true

func explode(_position):
	var e = bomb_explosion.instance()
	e.position = _position + Vector2(0, 30)
#	print("explosion position = " + str(e.position))
	e.emitting = true
	add_child(e)
	
func score_player_collects_coin():
	score += 1
	score_label.text = "SCORE " + str(score) + "    " # trailing space	

func player_life_lost():
	life_left -= 1
	life_label.text = "LIVES " + str(life_left)

func _on_bomb_drop_timer_timeout():
	ready_to_drop_bomb = true
	pass # replace with function body

func _on_coin_drop_timer_timeout():
	ready_to_drop_coin = true
	pass # replace with function body
