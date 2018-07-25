extends CanvasLayer

func _show():
	get_node("Ship").show()
	get_node("Weapon").show()
	get_node("Radar").show()
	get_node("FPS").show()
	set_process(true)

func _hide():
	get_node("Ship").hide()
	get_node("Weapon").hide()
	get_node("Radar").hide()
	get_node("FPS").hide()
	set_process(false)

func warning():
	get_node("AnimationAlarm").play("warning")

func _process(delta):
	if (has_node("/root/Level/Player")):
		var player = get_node("/root/Level/Player")
		for i in range(10,max(player.hp,0),-1):
			get_node("Ship/HP/HP"+str(i)).hide()
		for i in range(1,max(player.hp,0)+1):
			get_node("Ship/HP/HP"+str(i)).show()
		for i in range(10,player.sp,-1):
			get_node("Ship/SP/SP"+str(i)).hide()
		for i in range(1,player.sp+1):
			get_node("Ship/SP/SP"+str(i)).show()
		for i in range(5,player.upgrade,-1):
			get_node("Weapon/Upgrade/UP"+str(i)).hide()
		for i in range(1,player.upgrade+1):
			get_node("Weapon/Upgrade/UP"+str(i)).show()
		get_node("Ship/Score").set_text(str(floor(get_node("/root/Level").score)))
		get_node("Cross").set_frame(clamp(round(4*get_node("/root/Level/Player").shooting),0,3))
	get_node("Cross").set_global_position(get_node("Cross").get_global_mouse_position())
	get_node("FPS").set_text("FPS: "+str(Engine.get_frames_per_second()))

func _resized():
	var sc = OS.get_window_size()/Vector2(320,240)
	sc = max(round(min(sc.x,sc.y)),1.0)
	get_node("Ship").set_scale(sc*Vector2(1,1))
	get_node("Weapon").set_scale(sc*Vector2(1,1))
	get_node("Weapon").set_position(Vector2(16,OS.get_window_size().y-40-24*(sc-1)))
	get_node("Radar").set_scale(sc*Vector2(0.5,0.5))
	get_node("Radar").set_position(Vector2(OS.get_window_size().x-64*sc,OS.get_window_size().y-64*sc))

func _ready():
	get_tree().connect("screen_resized",self,"_resized")
	_resized()
