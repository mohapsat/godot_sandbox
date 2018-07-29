extends Node

var current = ""

onready var player = get_node("StreamPlayer")
onready var anim = get_node("Animation")


func change_to(new,fade_out=false):
	if (new==current):
		return
	
	if (fade_out):
		if (!anim.is_playing() || anim.get_current_animation()!="fade_out"):
			anim.play("fade_out")
		yield(anim,"animation_finished")
		anim.play("fade_in")
	else:
		anim.stop()
		player.set_volume_db(0)
	
	player.set_stream(load("res://music/"+new+".ogg"))
	player.play()
	current = new

func queue(new):
	if (player.is_playing()):
		yield(player,"finished")
	
	player.set_stream(load("res://music/"+new+".ogg"))
	player.play()
	current = new

func fade_out(time=1.0):
	current = ""
	anim.play("fade_out",-1,0.5/time)
	yield(anim,"animation_finished")
	player.stop()
