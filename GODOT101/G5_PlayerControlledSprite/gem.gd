extends Area2D

signal gem_grabbed

func _ready():
	pass

func _on_gem_area_entered(area):
#	print(area.get_name())
	if area.get_name() == 'player':
		queue_free()
		emit_signal("gem_grabbed")