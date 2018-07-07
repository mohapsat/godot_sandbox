extends Area2D

signal destroyed

const MOVE_SPEED = 200
# keep ship in screen
const SCREEN_WIDTH = 320
const SCREEN_HEIGHT = 180

var can_shoot = true
var destroyed = false

var shot_scene = preload("res://shot.tscn")
var explosion_scene = preload("res://explosion.tscn")


func _process(delta):
	
	var input_dir = Vector2()
	
	if Input.is_action_pressed("ui_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
		
	position = position + (delta * MOVE_SPEED) * input_dir
	
	if position.x < 0:
		position.x = 0
	elif position.x > SCREEN_WIDTH:
		position.x = SCREEN_WIDTH
	elif position.y < 0:
		position.y = 0
	elif position.y > SCREEN_HEIGHT:
		position.y = SCREEN_HEIGHT
	
#	print(position)			
	
	if Input.is_key_pressed(KEY_SPACE) and can_shoot:
		
		var stage_node = get_parent() #parent of player is stage
		
		var shot_instance1 = shot_scene.instance()
		shot_instance1.position = position + Vector2(9,-5)
		stage_node.add_child(shot_instance1)

		var shot_instance2 = shot_scene.instance()
		shot_instance2.position = position + Vector2(9,5)
		stage_node.add_child(shot_instance2)
		
		can_shoot = false
		get_node("reload_timer").start()


func _on_reload_timer_timeout():
	can_shoot = true


func _on_player_area_entered(area):

	if area.is_in_group("shot") or area.is_in_group("asteroid"):

		if not destroyed:
			destroyed = true
			emit_signal("destroyed")
		
			queue_free()
			
			var stage_node = get_parent()
			var explosion_instance = explosion_scene.instance()
			explosion_instance.position = position
			stage_node.add_child(explosion_instance)