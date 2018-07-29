extends Node

const TILE_TOP = 2
const TILE_RIGHT = 4
const TILE_BOTTOM = 6
const TILE_LEFT = 8
const TILE_CORNER_TL = 1
const TILE_CORNER_TR = 3
const TILE_CORNER_BR = 5
const TILE_CORNER_BL = 7
const TILE_INNER_BR = 9
const TILE_INNER_BL = 10
const TILE_INNER_TL = 11
const TILE_INNER_TR = 12

const N = {
	[0,0,0,
	 0,0,0,
	 0,1,0]:TILE_TOP,
	[0,0,0,
	 0,0,0,
	 0,1,1]:TILE_TOP,
	[0,0,0,
	 0,0,0,
	 1,1,0]:TILE_TOP,
	[0,0,0,
	 0,0,0,
	 1,1,1]:TILE_TOP,
	[0,0,0,
	 1,0,0,
	 0,0,0]:TILE_RIGHT,
	[1,0,0,
	 1,0,0,
	 0,0,0]:TILE_RIGHT,
	[0,0,0,
	 1,0,0,
	 1,0,0]:TILE_RIGHT,
	[1,0,0,
	 1,0,0,
	 1,0,0]:TILE_RIGHT,
	[0,1,0,
	 0,0,0,
	 0,0,0]:TILE_BOTTOM,
	[1,1,0,
	 0,0,0,
	 0,0,0]:TILE_BOTTOM,
	[0,1,1,
	 0,0,0,
	 0,0,0]:TILE_BOTTOM,
	[1,1,1,
	 0,0,0,
	 0,0,0]:TILE_BOTTOM,
	[0,0,0,
	 0,0,1,
	 0,0,0]:TILE_LEFT,
	[0,0,1,
	 0,0,1,
	 0,0,0]:TILE_LEFT,
	[0,0,0,
	 0,0,1,
	 0,0,1]:TILE_LEFT,
	[0,0,1,
	 0,0,1,
	 0,0,1]:TILE_LEFT,
	[0,0,0,
	 0,0,0,
	 0,0,1]:TILE_CORNER_TL,
	[0,0,0,
	 0,0,0,
	 1,0,0]:TILE_CORNER_TR,
	[1,0,0,
	 0,0,0,
	 0,0,0]:TILE_CORNER_BR,
	[0,0,1,
	 0,0,0,
	 0,0,0]:TILE_CORNER_BL,
	[0,1,0,
	 1,0,0,
	 0,0,0]:TILE_INNER_BR,
	[1,1,0,
	 1,0,0,
	 0,0,0]:TILE_INNER_BR,
	[1,1,1,
	 1,0,0,
	 0,0,0]:TILE_INNER_BR,
	[1,1,0,
	 1,0,0,
	 1,0,0]:TILE_INNER_BR,
	[1,1,1,
	 1,0,0,
	 1,0,0]:TILE_INNER_BR,
	[0,1,1,
	 1,0,0,
	 1,0,0]:TILE_INNER_BR,
	[0,1,1,
	 1,0,0,
	 0,0,0]:TILE_INNER_BR,
	[0,1,0,
	 1,0,0,
	 1,0,0]:TILE_INNER_BR,
	[0,1,0,
	 0,0,1,
	 0,0,0]:TILE_INNER_BL,
	[0,1,1,
	 0,0,1,
	 0,0,0]:TILE_INNER_BL,
	[1,1,1,
	 0,0,1,
	 0,0,0]:TILE_INNER_BL,
	[0,1,1,
	 0,0,1,
	 0,0,1]:TILE_INNER_BL,
	[1,1,1,
	 0,0,1,
	 0,0,1]:TILE_INNER_BL,
	[0,1,1,
	 0,0,1,
	 0,0,1]:TILE_INNER_BL,
	[1,1,0,
	 0,0,1,
	 0,0,0]:TILE_INNER_BL,
	[0,1,0,
	 0,0,1,
	 0,0,1]:TILE_INNER_BL,
	[0,0,0,
	 0,0,1,
	 0,1,0]:TILE_INNER_TL,
	[0,0,0,
	 0,0,1,
	 0,1,1]:TILE_INNER_TL,
	[0,0,0,
	 0,0,1,
	 1,1,1]:TILE_INNER_TL,
	[0,0,1,
	 0,0,1,
	 0,1,1]:TILE_INNER_TL,
	[0,0,1,
	 0,0,1,
	 1,1,1]:TILE_INNER_TL,
	[0,0,1,
	 0,0,1,
	 0,1,1]:TILE_INNER_TL,
	[0,0,0,
	 0,0,1,
	 1,1,0]:TILE_INNER_TL,
	[0,0,1,
	 0,0,1,
	 0,1,0]:TILE_INNER_TL,
	[0,0,0,
	 1,0,0,
	 0,1,0]:TILE_INNER_TR,
	[0,0,0,
	 1,0,0,
	 1,1,0]:TILE_INNER_TR,
	[0,0,0,
	 1,0,0,
	 1,1,1]:TILE_INNER_TR,
	[1,0,0,
	 1,0,0,
	 1,1,0]:TILE_INNER_TR,
	[1,0,0,
	 1,0,0,
	 1,1,1]:TILE_INNER_TR,
	[1,0,0,
	 1,0,0,
	 0,1,1]:TILE_INNER_TR,
	[0,0,0,
	 1,0,0,
	 0,1,1]:TILE_INNER_TR,
	[1,0,0,
	 1,0,0,
	 0,1,0]:TILE_INNER_TR
}

var difficulty = 0
var score = 0
var enemy = []
var time = 0.0
var delay = 0.0
onready var camera = get_node("Camera")

var enemies = [preload("res://scenes/enemy/enemy1.tscn"),preload("res://scenes/enemy/enemy1.tscn"),preload("res://scenes/enemy/enemy2.tscn")]


func _process(delta):
	time += delta
	delay -= delta
	if (has_node("Player")):
		var pos_p = get_node("Player").get_global_position()
		camera.set_position(pos_p)
		if (delay<=0.0):
			for e in enemy:
				if (e.get_global_position().distance_squared_to(pos_p)>10000000):
					e._disable()
			if (randf()<0.1):
				var ei = preload("res://scenes/enemy/large1.tscn").instance()
				var ang = 2*PI*randf()
				var pos = pos_p+Vector2(1000,0).rotated(ang)
				ei.set_global_position(pos)
				ei.set_rotation(ang)
				ei.hp = round(ei.hp*(10.0+difficulty)/10.0+difficulty)
				ei.set_linear_velocity(Vector2(-100,0).rotated(ang))
				add_child(ei)
				delay = (rand_range(1.0,4.0)+sqrt(enemy.size())*rand_range(0.2,0.4))*(10.0-difficulty)/10.0
			elif (randf()<0.1):
				var last
				var ang = 2*PI*randf()
				var pos = pos_p+Vector2(1000,0).rotated(ang)
				var parts = []
				parts.resize(randi()%6+6)
				for i in range(parts.size()):
					var ei = preload("res://scenes/enemy/snake.tscn").instance()
					ei.set_global_position(pos)
					ei.set_rotation(ang+PI)
					ei.hp = round(ei.hp*(10.0+difficulty)/10.0+difficulty)
					ei.set_linear_velocity(Vector2(-100,0).rotated(ang))
					if (last!=null):
						ei.get_node("PinJoint").set_node_b(last.get_path())
					add_child(ei)
					last = ei
					parts[i] = ei
					pos += Vector2(32,0).rotated(ang)
					for j in range(i):
						ei.add_collision_exception_with(parts[j])
				delay = (rand_range(1.0,3.0)+sqrt(enemy.size())*rand_range(0.2,0.4))*(10.0-difficulty)/10.0
			else:
				var ei = enemies[randi()%(enemies.size())].instance()
				var ang = 2*PI*randf()
				var pos = pos_p+Vector2(1500,0).rotated(ang)
				ei.set_global_position(pos)
				ei.set_rotation(ang+PI)
				ei.hp = round(ei.hp*(10.0+difficulty)/10.0+difficulty)
				add_child(ei)
				delay = (rand_range(0.25,2.0)+sqrt(enemy.size())*rand_range(0.2,0.4))*(10.0-difficulty)/10.0

func _resized():
	var scale = max(OS.get_window_size().x/400.0,OS.get_window_size().y/400.0)
	get_node("Background/ParallaxLayer/Water").set_scale(scale*Vector2(1,1))
	camera.set_zoom(2.0/round(scale)*Vector2(1,1))

func randomize_map():
	var map = {}
	get_node("Tilemap").clear()
	for i in range(125):
		var pos = Vector2(randi()%201-100,randi()%201-100)
		map[pos] = 0
		for j in range(randi()%6+1):
			pos += Vector2(randi()%3-1,randi()%3-1)
			map[pos] = 0
	
	for x in range(-4,5):
		for y in range(-100,9):
			var pos = Vector2(x,y)
			if (map.has(pos)):
				map.erase(pos)
	
	for k in range(2):
		for pos in map.keys():
			for x in range(-1,2):
				for y in range(-1,2):
					if (x==0 && y==0):
						continue
					var p = pos+Vector2(x,y)
					if (map.has(p) && map[p]==0):
						continue
					var array = []
					array.resize(9)
					for x1 in range(-1,2):
						for y1 in range(-1,2):
							var p1 = p+Vector2(x1,y1)
							if (map.has(p1)):
								array[x1+1+3*(y1+1)] = int(map[p1]==0)
							else:
								array[x1+1+3*(y1+1)] = 0
					if (N.has(array)):
						map[p] = N[array]
					elif (k==0):
						map[p] = 0
	
	for pos in map.keys():
		get_node("Tilemap").set_cell(pos.x,pos.y,map[pos])

func _ready():
	randomize()
	set_process(true)
	get_tree().connect("screen_resized",self,"_resized")
	_resized()
	delay = 0.5
	randomize_map()
	Music.change_to("Battle_1",true)
