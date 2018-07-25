extends Node

export (PackedScene) var trunk_scene

onready var first_trunk_position = $FirstTrunkPosition
onready var grave = $Grave
onready var time_left = $TimeLeft
onready var player = $Player
onready var timer = $Timer
onready var isDead = false
onready var score_counter = $Score 

var last_spawn_position
var score = 0
var spawn_with_axe = false
var spawn_right_axe = false

var trunks_arry = []

func _ready():
	last_spawn_position = first_trunk_position.position
	_spawn_empty_tree()

func _process(delta):
	if isDead:
		return
	time_left.value -= delta
	if time_left.value <= 0:
		die()
	
func _spawn_empty_tree():
	for counter in range (5):
		var new_trunk = trunk_scene.instance()
		add_child(new_trunk)
		new_trunk.position = last_spawn_position
		last_spawn_position.y -= new_trunk.sprite_height
		new_trunk.setup_trunk(false, false)
		trunks_arry.append(new_trunk)
		
func punch_tree(from_right):
	_setup_spawn_variables()
	_add_trunk()
	trunks_arry.front().remove(from_right)
	trunks_arry.pop_front()
	for trunk in trunks_arry:
		trunk.position.y += trunk.sprite_height
	time_left.value += 0.25
	if time_left.value > time_left.max_value:
		time_left.value = time_left.max_value
	score += 1
	score_counter.text = str(score)
		
		
func _add_trunk():
	var new_trunk = trunk_scene.instance()
	add_child(new_trunk)
	new_trunk.position = last_spawn_position
	new_trunk.setup_trunk(spawn_with_axe, spawn_right_axe)
	trunks_arry.append(new_trunk)

func _setup_spawn_variables():
	if spawn_with_axe:
		if rand_range(0, 100) > 50:
			spawn_with_axe = true
			#spawn trunk with axe in smae position as last
		else:
			spawn_with_axe = false
			#spawn bare trunk
	else:
		if rand_range(0, 100) > 50:
			spawn_right_axe = rand_range(0, 100) > 50
			spawn_with_axe = true
			#spawn bare trunk
		else:
			spawn_with_axe = false	
			#spawn bare trunk

func die():
	grave.position.x = player.position.x
	player.queue_free()
	grave.visible = true
	isDead = true
	timer.start()

func _on_Timer_timeout():
	get_tree().reload_current_scene()