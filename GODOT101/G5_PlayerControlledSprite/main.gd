extends Node

# preload gem texture
onready var gem = preload("res://gem.tscn")
onready var level_label = preload("res://level_label.tscn")
onready var timer_label = get_node("timer_label")
onready var game_timer = get_node("game_timer")

var screensize
var score = 0
var level = 1

func _ready():
	screensize = get_viewport().size
	spawn_gems(3)


func _process(delta):
	
	timer_label.text = str(int(game_timer.get_time_left()))
		
	if $gem_container.get_child_count() == 0:
		level += 1
		$level_label.text = "LEVEL " + str(level)
		spawn_gems(level * 3)
		game_timer.start()
		
		
		
func spawn_gems(num):
	randomize() # randomize rand_range seed
	for i in range(num):
		var g = gem.instance()
		$gem_container.add_child(g)
		
		g.connect("gem_grabbed", self, "_on_gem_grabbed")
		
		g.position.x = rand_range(0,screensize.x)
		g.position.y = rand_range(0,screensize.y)
		
func _on_gem_grabbed():
	score += 1
	$score_label.text = "SCORE: " + str(score)	


func _on_game_timer_timeout():
	pass # replace with function body
