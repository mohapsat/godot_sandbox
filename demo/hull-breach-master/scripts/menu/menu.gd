extends Node

const VERSION = "v0.9.3"
const ACTIONS = ["thrust","reverse_thrust","strafe_left","strafe_right","rotate_left","rotate_right","shoot","special"]
const SHIPS = [
{"hp":4,"sp":4,"la": 75.0,"aa":3.5,"weapon":0,"fire_rate":5.0,"scene":preload("res://scenes/ships/ship1.tscn"),"s_icon":preload("res://images/gui/ship1_icon.png"),"w_icon":preload("res://images/gui/weapon_mg.png")},
{"hp":4,"sp":5,"la":100.0,"aa":5.0,"weapon":1,"fire_rate":8.0,"scene":preload("res://scenes/ships/ship2.tscn"),"s_icon":preload("res://images/gui/ship2_icon.png"),"w_icon":preload("res://images/gui/weapon_bl.png")},
{"hp":5,"sp":3,"la": 55.0,"aa":1.5,"weapon":2,"fire_rate":2.0,"scene":preload("res://scenes/ships/ship3.tscn"),"s_icon":preload("res://images/gui/ship3_icon.png"),"w_icon":preload("res://images/gui/weapon_pb.png")}]

var thread
var dir = Directory.new()
var file = File.new()
var ship_selected = 0
var difficulty = 0
var settings = {}
var old_settings = {}
var key_binds = {}
var old_key_binds = {}
var highscores = []
var action_selected = ""
var hs_level = 0
var hs_name = ""
var hs_score = 0
var new_event
var started = false


func load_level(arg=null):
	var level = load("res://scenes/main/level.tscn")
	call_deferred("_load_done",level)
	return level

func _load_done(level):
	if (level==null || !level.can_instance()):
		show_menu()
		started = false
		return
	
	_start_level(level)

func _start_level(level):
	var s = SHIPS[ship_selected]
	var ship = s["scene"].instance()
	level = level.instance()
	level.difficulty = difficulty
	ship.hp = s["hp"]
	ship.hp_max = s["hp"]
	ship.sp = clamp(round(s["sp"]/2.0-difficulty),0,s["sp"])
	ship.sp_max = s["sp"]
	ship.la = s["la"]
	ship.aa = s["aa"]
	ship.weapon = s["weapon"]
	ship.delay = 1.0/s["fire_rate"]
	ship.set_linear_velocity(Vector2(0,-250.0))
	ship.set_rotation(-PI/2.0)
	level.add_child(ship)
	get_tree().get_root().add_child(level)
	ship.set_global_position(level.get_node("Carrier/Bay"+str(randi()%2+1)).get_global_position())
	UI.get_node("Ship/Icon").set_texture(s["s_icon"])
	UI.get_node("Weapon/Icon").set_texture(s["w_icon"])
	UI._show()
	get_node("Animation").play("fade_in")

func _start():
	save_settings()
	started = true
	UI.get_node("Radar").detected.clear()
	if (!OS.can_use_threads()):
		# loading in a thread does not work
		load_level()
	else:
		thread = Thread.new()
		thread.start(self,"load_level",null,Thread.PRIORITY_HIGH)
	hide_menu()
	get_node("Animation").play("fade_out")

func _game_over(s):
	_unpause()
	get_node("Animation").play("fade_out")
	yield(get_node("Animation"),"animation_finished")
	hs_score = floor(s*(1.0+0.25*difficulty))
	if (has_node("/root/Level")):
		get_node("/root/Level").queue_free()
	started = false
	show_menu()
	UI._hide()
	if (s>0):
		check_highscore()
	_show_level()
	get_node("Animation").play("fade_in")
	Music.fade_out(3.0)

func check_highscore():
	for i in range(highscores.size()):
		if (highscores[i]["score"]<=hs_score || highscores[i].size()<15):
			show_highscore()


# menu stuff

func _show_level():
	get_node("Player").hide()
	get_node("Options").hide()
	get_node("Level").show()
	get_node("Credits").hide()
	get_node("AddKey").hide()
	update_highscore()

func _show_player():
	_select_ship(ship_selected)
	get_node("Player").show()
	get_node("Options").hide()
	get_node("Level").hide()
	get_node("Credits").hide()
	get_node("AddKey").hide()

func _show_options():
	if (!get_node("Options").visible):
		for k in settings.keys():
			old_settings[k] = settings[k]
		for k in key_binds.keys():
			old_key_binds[k] = key_binds[k]
	update_key_binds()
	get_node("Player").hide()
	get_node("Options").show()
	get_node("Level").hide()
	get_node("Credits").hide()
	get_node("AddKey").hide()

func _show_credits():
	get_node("Player").hide()
	get_node("Options").hide()
	get_node("Level").hide()
	get_node("Credits").show()
	get_node("AddKey").hide()

func _show_res():
	get_node("Options/Resolution").show()
	get_node("Options/Audio").hide()
	get_node("Options/Control").hide()

func _show_snd():
	get_node("Options/Resolution").hide()
	get_node("Options/Audio").show()
	get_node("Options/Control").hide()

func _show_ctrl():
	get_node("Options/Resolution").hide()
	get_node("Options/Audio").hide()
	get_node("Options/Control").show()

func show_highscore():
	hs_name = ""
	get_node("Highscore/LineEdit").set_text(hs_name)
	get_node("Highscore").show()

func _select_ship(ID):
	get_node("Player/HBoxContainer/Ship"+str(ship_selected+1)+"/Select").hide()
	ship_selected = ID
	get_node("Player/HBoxContainer/Ship"+str(ship_selected+1)+"/Select").show()

func hide_menu():
	for c in get_children():
		if (c.has_method("hide")):
			c.hide()

func show_menu():
	get_node("Panel").show()
	get_node("Player").hide()
	get_node("Options").hide()
	get_node("Level").hide()
	get_node("AddKey").hide()
	get_node("Background").show()

func _show_resolution():
	get_node("Options/Resolution").show()
	get_node("Options/Audio").hide()
	get_node("Options/Control").hide()

func _show_sound():
	get_node("Options/Resolution").hide()
	get_node("Options/Audio").show()
	get_node("Options/Control").hide()

func _show_control():
	get_node("Options/Resolution").hide()
	get_node("Options/Audio").hide()
	get_node("Options/Control").show()
	update_key_binds()

func _quit():
	save_settings()
	get_tree().quit()

func _pause():
	get_tree().set_pause(true)
	get_node("Pause").show()

func _unpause():
	get_tree().set_pause(false)
	get_node("Pause").hide()


# load/save

func _create_dir():
	if (!dir.dir_exists("user://")):
		dir.make_dir_recursive("user://")

func load_settings():
	file = File.new()
	if (!file.file_exists("user://settings.cfg")):
		default_settings()
		update_key_binds()
		default_hs()
		return 
	
	var error = file.open("user://settings.cfg",File.READ)
	default_settings()
	if (error==OK):
		var currentline = JSON.parse(file.get_line()).result
		for s in currentline.keys():
			settings[s] = currentline[s]
		currentline = {}
		currentline = JSON.parse(file.get_line()).result
		for action in currentline.keys():
			key_binds[action] = currentline[action]
		currentline = {}
		currentline = JSON.parse(file.get_line()).result
	
	for action in key_binds.keys():
		for i in range(key_binds[action].size()):
			var ev = InputEvent()
			ev.type = key_binds[action][i]["type"]
			if (ev.type==InputEvent.KEY):
				ev.scancode = key_binds[action][i]["scancode"]
			elif (ev.type==InputEvent.MOUSE_BUTTON):
				ev.button_index = key_binds[action][i]["button_index"]
			if (!InputMap.action_has_event(action,ev)):
				InputMap.action_add_event(action,ev)
	
	file.close()
	error = file.open("user://highscores.json",File.READ)
	if (error==OK):
		var currentline = JSON.parse(file.get_line()).result
		highscores = currentline
	if (error!=OK || highscores==null || highscores.size()==0):
		default_hs()
	
	update_key_binds()
	apply_resolution()

func save_settings():
	var dir = Directory.new()
	file = File.new()
	if (!dir.dir_exists("user://")):
		dir.make_dir_recursive("user://")
	
	var error = file.open("user://settings.cfg",File.WRITE)
	if (error==OK):
		file.store_line(JSON.print(settings))
		file.store_line(JSON.print(key_binds))
		file.close()
	error = file.open("user://highscores.json",File.WRITE)
	if (error==OK):
		file.store_line(JSON.print(highscores))
		file.close()

func default_hs():
	highscores.resize(10)
	for i in range(10):
		highscores[i] = {"score":100*round(2+0.7*(10-i)*sqrt(10-i)),"name":"NAME"+str(i+1)}


# settings

func default_settings():
	settings["resolution_x"] = OS.get_screen_size().x
	settings["resolution_y"] = OS.get_screen_size().y
	settings["fullscreen"] = false
	settings["maximized"] = true
	settings["music"] = 1.0
	settings["sound"] = 1.0

func update_key_binds():
	for action in ACTIONS:
		var keys = InputMap.get_action_list(action)
		for event in keys:
			var _name = action.capitalize().replace(" ","")
			if (event is InputEventKey && !has_node("Options/Control/VBoxContainer/"+_name+"/Button_"+str(event.scancode))):
				var bi = get_node("Options/Button").duplicate()
				bi.set_text(OS.get_scancode_string(event.scancode))
				bi.connect("pressed",self,"remove_key",[action,event])
				bi.connect("focus_entered",get_node("SoundH"),"play")
				bi.connect("mouse_entered",get_node("SoundH"),"play")
				bi.connect("pressed",get_node("SoundP"),"play")
				bi.set_name("Button_"+str(event.scancode))
				get_node("Options/Control/VBoxContainer/"+_name).add_child(bi)
				bi.show()

func add_key(action,event):
	if (InputMap.action_has_event(action,event)):
		return
	
	var _name = action.capitalize().replace(" ","")
	InputMap.action_add_event(action,event)
	if (!has_node("Options/Control/VBoxContainer/"+_name+"/Button_"+str(event.scancode))):
		var bi = get_node("Options/Button").duplicate()
		bi.set_text(OS.get_scancode_string(event.scancode))
		bi.connect("pressed",self,"remove_key",[action,event])
		bi.connect("focus_entered",get_node("Sound"),"play")
		bi.connect("mouse_entered",get_node("Sound"),"play")
		bi.connect("pressed",get_node("Sound"),"play")
		bi.set_name("Button_"+str(event.scancode))
		get_node("Options/Control/VBoxContainer/"+_name).add_child(bi)
		bi.show()

func remove_key(action,event):
	var _name = action.capitalize().replace(" ","")
	InputMap.action_erase_event(action,event)
	if (has_node("Options/Control/VBoxContainer/"+_name+"/Button_"+str(event.scancode))):
		get_node("Options/Control/VBoxContainer/"+_name+"/Button_"+str(event.scancode)).queue_free()

func _add_new_key():
	add_key(action_selected,new_event)
	get_node("AddKey").hide()

func _show_add_key(action):
	action_selected = action
	get_node("AddKey").show()

func _apply_settings():
	get_node("Options").hide()
	if (settings["resolution_x"]!=old_settings["resolution_x"] || settings["resolution_y"]!=old_settings["resolution_y"] || settings["fullscreen"]!=old_settings["fullscreen"]):
		apply_resolution()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear2db(settings["music"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"),linear2db(settings["sound"]))
	get_node("Options/Audio/Music/SpinBox").set_value(100*settings["music"])
	get_node("Options/Audio/Sound/SpinBox").set_value(100*settings["sound"])

func _revert_settings():
	get_node("Options").hide()
	for k in settings.keys():
		settings[k] = old_settings[k]
	for k in key_binds.keys():
		key_binds[k] = old_key_binds[k]

func _select_difficulty(ID):
	difficulty = ID
	for i in range(3):
		get_node("Level/VBoxContainer/Button"+str(i+1)).set_pressed(difficulty+1==i)

func _set_fullscreen(pressed):
	settings["fullscreen"] = pressed

func _set_resolution_x(value):
	settings["resolution_x"] = value

func _set_resolution_y(value):
	settings["resolution_y"] = value

func _set_music(value):
	settings["music"] = value/100.0

func _set_sound(value):
	settings["sound"] = value/100.0

func _change_name(text):
	hs_name = text

func _add_highscore():
	var rank = -1
	get_node("Highscore").hide()
	for i in range(highscores.size()):
		if (highscores[i]["score"]<=hs_score):
			rank = i
			break
	if (rank==-1):
		if (highscores.size()<15):
			rank = highscores.size()
		else:
			return
	
	highscores.resize(min(max(highscores.size()+1,rank-1),15))
	for i in range(highscores.size()-1,rank,-1):
		highscores[i] = highscores[i-1]
	highscores[rank] = {"score":hs_score,"name":hs_name}
	update_highscore()

func apply_resolution():
	OS.set_window_fullscreen(settings["fullscreen"])
	OS.set_window_maximized(settings["maximized"])
	OS.set_window_size(Vector2(settings["resolution_x"],settings["resolution_y"]))
	get_node("Options/Resolution/Fullscreen/CheckBox").set_pressed(settings["fullscreen"])
	get_node("Options/Resolution/Resolution/ResX").set_value(settings["resolution_x"])
	get_node("Options/Resolution/Resolution/ResY").set_value(settings["resolution_y"])

func update_highscore():
	if (highscores==null || highscores.size()==0):
		return
	
	var ranks = ""
	var scores = ""
	var names = ""
	for i in range(highscores.size()):
		ranks += str(i+1)+"\n"
		scores += str(highscores[i]["score"])+"\n"
		names += str(highscores[i]["name"])+"\n"
	get_node("Level/Ranks").set_text(ranks)
	get_node("Level/Scores").set_text(scores)
	get_node("Level/Names").set_text(names)

func _resized():
	var scale = OS.get_window_size()/Vector2(320,240)
	scale = max(round(min(scale.x,scale.y)),1.0)
	get_node("Panel").set_scale(scale*Vector2(1,1))
	get_node("Panel").set_position((OS.get_window_size()-scale*get_node("Panel").get_size())*Vector2(0.75,0.5))
	get_node("Player").set_scale(scale*Vector2(1,1))
	get_node("Player").set_position((OS.get_window_size()-scale*get_node("Player").get_size())/2)
	get_node("Level").set_scale(scale*Vector2(1,1))
	get_node("Level").set_position((OS.get_window_size()-scale*get_node("Level").get_size())/2)
	get_node("Options").set_scale(scale*Vector2(1,1))
	get_node("Options").set_position((OS.get_window_size()-scale*get_node("Options").get_size())/2)
	get_node("Credits").set_scale(scale*Vector2(1,1))
	get_node("Credits").set_position((OS.get_window_size()-scale*get_node("Credits").get_size())/2)
	get_node("AddKey").set_scale(scale*Vector2(1,1))
	get_node("AddKey").set_position((OS.get_window_size()-scale*get_node("AddKey").get_size())/2)
	get_node("Highscore").set_scale(scale*Vector2(1,1))
	get_node("Highscore").set_position((OS.get_window_size()-scale*get_node("AddKey").get_size())/2)
	get_node("Pause").set_scale(scale*Vector2(1,1))
	get_node("Pause").set_position((OS.get_window_size()-scale*get_node("AddKey").get_size())/2)
	settings["fullscreen"] = OS.is_window_fullscreen()
	settings["maximized"] = OS.is_window_maximized()
	settings["resolution_x"] = OS.get_window_size().x
	settings["resolution_y"] = OS.get_window_size().y
	get_node("Options/Resolution/Resolution/ResX").set_value(settings["resolution_x"])
	get_node("Options/Resolution/Resolution/ResY").set_value(settings["resolution_y"])

func _input(event):
	if (event is InputEventKey):
		if (event.is_action_pressed("ui_cancel")):
			if (!started):
				if (get_node("AddKey").visible):
					show_menu()
			elif (get_node("Pause").is_visible()):
				_unpause()
			else:
				_pause()
		elif (get_node("AddKey").visible):
			new_event = event
			get_node("AddKey/Label").set_text(OS.get_scancode_string(event.scancode))
			get_node("AddKey/ButtonA").grab_focus()

func _ready():
	get_tree().connect("screen_resized",self,"_resized")
	get_node("Panel/VBoxContainer/Button1").grab_focus()
	set_process_input(true)
	get_node("Version").set_text(VERSION)
	
	if (OS.has_feature("web")):
		get_node("Panel/VBoxContainer/Button2").hide()
	# Connect buttons.
	get_node("Panel/VBoxContainer/Button1").connect("pressed",self,"_show_level")
	get_node("Panel/VBoxContainer/Button3").connect("pressed",self,"_show_options")
	get_node("Panel/VBoxContainer/Button4").connect("pressed",self,"_show_credits")
	get_node("Panel/VBoxContainer/Button2").connect("pressed",self,"_quit")
	for i in range(3):
		get_node("Player/HBoxContainer/Ship"+str(i+1)).connect("pressed",self,"_select_ship",[i])
	get_node("Player/Button").connect("pressed",self,"_start")
	get_node("Level/Button").connect("pressed",self,"_show_player")
	for i in range(3):
		get_node("Level/VBoxContainer/Button"+str(i+1)).connect("pressed",self,"_select_difficulty",[i-1])
	get_node("Options/VBoxContainer/ButtonR").connect("pressed",self,"_show_res")
	get_node("Options/VBoxContainer/ButtonS").connect("pressed",self,"_show_snd")
	get_node("Options/VBoxContainer/ButtonC").connect("pressed",self,"_show_ctrl")
	get_node("Options/Resolution/Fullscreen/CheckBox").connect("toggled",self,"_set_fullscreen")
	get_node("Options/Resolution/Resolution/ResX").connect("value_changed",self,"_set_resolution_x")
	get_node("Options/Resolution/Resolution/ResY").connect("value_changed",self,"_set_resolution_y")
	get_node("Options/Audio/Music/SpinBox").connect("value_changed",self,"_set_music")
	get_node("Options/Audio/Sound/SpinBox").connect("value_changed",self,"_set_sound")
	get_node("Pause/Button1").connect("pressed",self,"_unpause")
	get_node("Pause/Button2").connect("pressed",self,"_game_over",[0])
	for action in ACTIONS:
		var string = action.capitalize().replace(" ","_")
		var button = get_node("Options/Control/VBoxContainer/Base").duplicate()
		button.set_name(string.replace("_",""))
		button.get_node("Label").set_text(tr(string))
		button.get_node("ButtonAdd").connect("pressed",self,"_show_add_key",[action])
		button.get_node("ButtonAdd").connect("focus_entered",get_node("SoundH"),"play")
		button.get_node("ButtonAdd").connect("mouse_entered",get_node("SoundH"),"play")
		button.get_node("ButtonAdd").connect("pressed",get_node("SoundP"),"play")
		get_node("Options/Control/VBoxContainer").add_child(button)
		button.show()
	get_node("Options/ButtonA").connect("pressed",self,"_apply_settings")
	get_node("Options/ButtonC").connect("pressed",self,"_revert_settings")
	get_node("Options/Panel/Button").connect("pressed",self,"_revert_settings")
	get_node("AddKey/ButtonA").connect("pressed",self,"_add_new_key")
	get_node("Highscore/LineEdit").connect("text_changed",self,"_change_name")
	get_node("Highscore/Button").connect("pressed",self,"_add_highscore")
	
	# Connect UI sounds.
	for c in get_node("Panel/VBoxContainer").get_children()+get_node("Player/HBoxContainer").get_children()+get_node("Level/VBoxContainer").get_children()+get_node("Options/VBoxContainer").get_children():
		c.connect("focus_entered",get_node("SoundH"),"play")
		c.connect("mouse_entered",get_node("SoundH"),"play")
		c.connect("pressed",get_node("SoundP"),"play")
	get_node("Player/Panel/Button").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Player/Panel/Button").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Player/Panel/Button").connect("pressed",get_node("SoundP"),"play")
	get_node("Player/Button").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Player/Button").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Player/Button").connect("pressed",get_node("SoundP"),"play")
	get_node("Level/Panel/Button").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Level/Panel/Button").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Level/Panel/Button").connect("pressed",get_node("SoundP"),"play")
	get_node("Level/Button").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Level/Button").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Level/Button").connect("pressed",get_node("SoundP"),"play")
	get_node("Options/Panel/Button").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Options/Panel/Button").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Options/Panel/Button").connect("pressed",get_node("SoundP"),"play")
	get_node("Options/Button").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Options/Button").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Options/Button").connect("pressed",get_node("SoundP"),"play")
	get_node("Options/ButtonA").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Options/ButtonA").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Options/ButtonA").connect("pressed",get_node("SoundP"),"play")
	get_node("Options/ButtonC").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Options/ButtonC").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Options/ButtonC").connect("pressed",get_node("SoundP"),"play")
	get_node("Options/Resolution/Fullscreen/CheckBox").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Options/Resolution/Fullscreen/CheckBox").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Options/Resolution/Fullscreen/CheckBox").connect("pressed",get_node("SoundP"),"play")
	get_node("Options/Resolution/Resolution/ResX").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Options/Resolution/Resolution/ResX").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Options/Resolution/Resolution/ResX").connect("changed",get_node("SoundP"),"play")
	get_node("Options/Resolution/Resolution/ResY").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Options/Resolution/Resolution/ResY").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Options/Resolution/Resolution/ResY").connect("changed",get_node("SoundP"),"play")
	get_node("Options/Audio/Music/SpinBox").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Options/Audio/Music/SpinBox").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Options/Audio/Music/SpinBox").connect("changed",get_node("SoundP"),"play")
	get_node("Options/Audio/Sound/SpinBox").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Options/Audio/Sound/SpinBox").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Options/Audio/Sound/SpinBox").connect("changed",get_node("SoundP"),"play")
	get_node("AddKey/Panel/Button").connect("focus_entered",get_node("SoundH"),"play")
	get_node("AddKey/Panel/Button").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("AddKey/Panel/Button").connect("pressed",get_node("SoundP"),"play")
	get_node("AddKey/ButtonA").connect("focus_entered",get_node("SoundH"),"play")
	get_node("AddKey/ButtonA").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("AddKey/ButtonA").connect("pressed",get_node("SoundP"),"play")
	get_node("AddKey/ButtonC").connect("focus_entered",get_node("SoundH"),"play")
	get_node("AddKey/ButtonC").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("AddKey/ButtonC").connect("pressed",get_node("SoundP"),"play")
	get_node("Highscore/Panel/Button").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Highscore/Panel/Button").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Highscore/Panel/Button").connect("pressed",get_node("SoundP"),"play")
	get_node("Highscore/Button").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Highscore/Button").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Highscore/Button").connect("pressed",get_node("SoundP"),"play")
	get_node("Highscore/LineEdit").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Highscore/LineEdit").connect("text_entered",get_node("SoundP"),"play")
	get_node("Pause/Button1").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Pause/Button1").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Pause/Button1").connect("pressed",get_node("SoundP"),"play")
	get_node("Pause/Button2").connect("focus_entered",get_node("SoundH"),"play")
	get_node("Pause/Button2").connect("mouse_entered",get_node("SoundH"),"play")
	get_node("Pause/Button2").connect("pressed",get_node("SoundP"),"play")
	
	load_settings()
	show_menu()
	_resized()
	Music.change_to("intro")
	get_node("Credits/Text").push_font(preload("res://fonts/font_green.tres"))
	get_node("Credits/Text").add_text("Hull Breach Credits\n\n\n")
	get_node("Credits/Text").add_text(tr("ENGINE")+"\n\n")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text("Godot 3.0.2 (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=https://godotengine.org/]{godotengine.org}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n\n\n")
	get_node("Credits/Text").push_font(preload("res://fonts/font_green.tres"))
	get_node("Credits/Text").add_text(tr("GRAPHICS")+"\n\n")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text("- Viktor Hahn\n")
	get_node("Credits/Text").add_text("- "+tr("FONT")+" "+tr("BY")+" thekingphoenix (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=https://opengameart.org/content/font-0]{opengameart.org}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n\n\n")
	get_node("Credits/Text").push_font(preload("res://fonts/font_green.tres"))
	get_node("Credits/Text").add_text(tr("MUSIC")+"\n\n")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text("- INTRO "+tr("BY")+" Jason Dagenet (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=https://opengameart.org/content/intro-sequence]{opengameart.org}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n")
	get_node("Credits/Text").add_text("- Battle_1 "+tr("BY")+" Alexandr Zhelanov (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=https://soundcloud.com/alexandr-zhelanov]{soundcloud.com/alexandr-zhelanov}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n\n\n")
	get_node("Credits/Text").push_font(preload("res://fonts/font_green.tres"))
	get_node("Credits/Text").add_text(tr("SOUNDS")+"\n\n")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text("- "+tr("UI_SOUNDS")+" "+tr("BY")+" Circlerun (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=https://opengameart.org/content/hi-tech-button-sound-pack-i-non-themed]{opengameart.org}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n")
	get_node("Credits/Text").add_text("- Laser_05 "+tr("BY")+" Little Robot Sound Factory (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=http://www.littlerobotsoundfactory.com]{www.littlerobotsoundfactory.com}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n")
	get_node("Credits/Text").add_text("- cg1, flaunch, rlaunch "+tr("BY")+" Michel Baradari (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=http://apollo-music.de]{apollo-music.de}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n")
	get_node("Credits/Text").add_text("- 16, 17 "+tr("BY")+" HorrorPen (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=https://opengameart.org/content/41-random-sound-effects]{opengameart.org}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n")
	get_node("Credits/Text").add_text("- "+tr("SPACE_SHIELD_SOUNDS")+" "+tr("BY")+" bart (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=https://opengameart.org/content/space-ship-shield-sounds]{opengameart.org}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n")
	get_node("Credits/Text").add_text("- "+tr("ALARM_AND_IMPACT_SOUNDS")+" "+tr("BY")+" Juhani Junkala (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=https://opengameart.org/content/512-sound-effects-8-bit-style]{opengameart.org}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n")
	get_node("Credits/Text").add_text("- "+tr("EXPLOSION_SOUNDS")+" "+tr("BY")+" Viktor Hahn (")
	get_node("Credits/Text").push_font(preload("res://fonts/font_blue.tres"))
	get_node("Credits/Text").append_bbcode("[url=https://opengameart.org/content/9-explosion-sounds]{opengameart.org}[/url]")
	get_node("Credits/Text").push_font(preload("res://fonts/font_yellow.tres"))
	get_node("Credits/Text").add_text(")\n")
	get_node("Credits/Text").connect("meta_clicked",OS,"shell_open")
