extends Node

# preload gem texture
onready var gem = preload("res://gem.tscn")
onready var level_label = preload("res://level_label.tscn")

var screensize
var score = 0
var level = 1

func _ready():
	screensize = get_viewport().size
	spawn_gems(10)
	


func _process(delta):
	
	if $gem_container.get_child_count() == 0:
		level += 1
		$level_label.text = "LEVEL " + str(level)
		spawn_gems(level * 10)
		
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
	print(score)