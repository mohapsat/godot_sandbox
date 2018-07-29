extends Node

onready var sprite = preload("res://Sprite.tscn")
# onready ensures resource is loaded to disc before _ready runs

func _ready():
	for i in range(10):
		var s = sprite.instance()
		add_child(s)

