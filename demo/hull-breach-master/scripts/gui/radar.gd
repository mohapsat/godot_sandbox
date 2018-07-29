extends TextureRect

var detected = []
var active = false
var radar_range = 64.0
var delay = 2.0
var zoom = 0.05
var progress = 0.0
onready var offset = rect_size/2.0

var dot = preload("res://scenes/gui/radar_dot_new.tscn")
var icon = preload("res://scenes/gui/warning.tscn")
var tex = preload("res://images/gui/radar_dot.png")


func _draw():
	if (!has_node("/root/Level") || !has_node("/root/Level/Player") || get_node("/root/Level/Player").disabled):
		return
	
	var tilemap = get_node("/root/Level/Tilemap")
	var p = tilemap.world_to_map(get_node("/root/Level/Player").get_global_position())
	for x in range(-18,19):
		for y in range(-floor(18*sin((x+18)/36.0*PI)),ceil(19*sin((x+18)/36.0*PI))):
			if (tilemap.get_cell(p.x+x,p.y+y)>=0):
				var pos = zoom*(tilemap.map_to_world(p+Vector2(x,y))-get_node("/root/Level/Player").get_global_position())+offset
				draw_circle(pos,1.5,Color(0.5,0.5,0.5,0.5))
	
	for e in detected:
		var pos = zoom*(e.get_global_position()-get_node("/root/Level/Player").get_global_position())+offset
		if (!get_node("/root/Level").enemy.has(e)):
			if ((pos-Vector2(64.0,64.0)).length_squared()<radar_range*radar_range):
				var di = dot.instance()
				di.set_position(pos)
				di.set_self_modulate(Color(1.0,0.1,0.1))
				di.set_scale(e.size*Vector2(1,1))
				add_child(di)
				di.get_node("Animation").play("destroy")
			detected.erase(e)
			if (e.has_node("Warning")):
				e.get_node("Warning/Animation").play("fade_out")
		elif ((pos-Vector2(64.0,64.0)).length_squared()<radar_range*radar_range):
			draw_circle(pos,e.size,Color(1.0,0.0,0.0,1.0))
	
	if (!active):
		return
	
	for e in get_node("/root/Level").enemy:
		var pos = zoom*(e.get_global_position()-get_node("/root/Level/Player").get_global_position())+offset
		if ((pos-Vector2(64.0,64.0)).length_squared()<radar_range*radar_range*progress/0.6*progress/0.6):
			if !(e in detected):
				var di = dot.instance()
				di.set_position(pos)
				di.set_self_modulate(Color(1.0,0.1,0.1))
				di.set_scale(e.size*Vector2(1,1))
				add_child(di)
				di.get_node("Animation").play("new")
				detected.push_back(e)
				UI.get_node("SoundAlarm").play()
			if (!e.has_node("Warning")):
				var ii = icon.instance()
				ii.size = e.size
				e.add_child(ii)

func _process(delta):
	delay -= delta
	if (!active && delay<=0.0 && has_node("/root/Level")):
		progress = 0.0
		get_node("Animation").play("radar")
		get_node("Sound").play()
		active = true
	if (active):
		progress += delta
		if (progress>=0.6):
			active = false
			delay = 1.0
	update()

func _ready():
	set_process(true)
