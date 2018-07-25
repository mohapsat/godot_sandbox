#tool
extends Node2D

var pixelsPerSpring = 4

var _width = 1024 setget _private, _private

var Tension = 0.05; 
var Dampening = 0.025;
var Spread = 0.25;

var Spring = preload("res://addons/Test/waterColumn.gd")

func _private(value = null):
	print("Invalid access to private variable!")
	return value

var width setget set_width, get_width

var springs
var polyNode

func _ready():
	
	_refresh_child()
	pass


func _get_property_list():
	return [
		{usage = PROPERTY_USAGE_CATEGORY, type = TYPE_NIL, name = "Water2D"},
		{type = TYPE_INT, name = "width"},
		{type = TYPE_INT, name = "pixelsPerSpring"}
		
	]

func get_width():
	return _width
	pass

func set_width(w):
	_width = w
	_refresh_child()
	pass

func _refresh_child():
	if get_viewport() == null:
		# We don't yet have a viewport.
		return
	
	springs = []
	
	if not has_node("Polygon"):
		var polyNode = Polygon2D.new()
		polyNode.set_name("Polygon")
		add_child(polyNode)
	
	var poly = PoolVector2Array()
	
	#var s = spring.new()
	for i in range(0,_width/pixelsPerSpring+1):
		var y = sin(i*pixelsPerSpring/100.0)*50
		poly.append(Vector2(0+pixelsPerSpring*i,y))
		springs.append(Spring.new())
		springs[i].Height = 0
	
	poly.append(Vector2(_width,400))
	poly.append(Vector2(0,400))
	
	
	polyNode = get_node("Polygon")
	
	polyNode.polygon = poly
	
	pass


func _input(event):
	
	if event.is_action_pressed("Jump"):
		springs[100].Height = 200.0
		pass
	pass

func _process(delta):
#	if true:
	#if not Engine.iseditor_hint():
		#for spring in springs:
			
		#	pass
	var lDeltas = []
	var rDeltas = []
		
	for i in range(0,_width/pixelsPerSpring+1):
		springs[i].Update(Dampening, Tension)
		polyNode.polygon[i].y = springs[i].Height
		lDeltas.append( 0)
		rDeltas.append( 0)
		pass
	
	
	for loops in range(0,8):
		for i in range(0,len(springs)):
			if i > 0:
				lDeltas[i] = Spread * (springs[i].Height - springs[i - 1].Height);
				springs[i - 1].Speed += lDeltas[i];
				pass
			if i < len(springs) - 1:
				rDeltas[i] = Spread * (springs[i].Height - springs[i + 1].Height);
				springs[i + 1].Speed += rDeltas[i];
			pass
		
		for i in range(0,len(springs)):
			if (i > 0):
				springs[i - 1].Height += lDeltas[i];
			if (i < len(springs) - 1):
				springs[i + 1].Height += rDeltas[i];
			pass
		pass
	

	for i in range(0,_width/pixelsPerSpring+1):
		polyNode.polygon[i].y = springs[i].Height
		pass
	pass