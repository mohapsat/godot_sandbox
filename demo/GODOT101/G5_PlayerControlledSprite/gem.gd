extends Area2D

onready var sprite = $"Sprite"
onready var effect = $"effect"

signal gem_grabbed

func _ready():
#	adding tween effect to gem, use interpolate property to
#	modify scale of sprite
	effect.interpolate_property(sprite, "scale", 
		sprite.get_scale(), Vector2(2.0, 2.0), 0.15,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
#	change opacity using visibilty / modulate property for sprite
	effect.interpolate_property(sprite, "modulate", 
		Color(1,1,1,1), Color(1, 1, 1, 0), 0.15,
		Tween.TRANS_QUAD, Tween.EASE_OUT)

func _on_gem_area_entered(area):
#	print(area.get_name())
	if area.get_name() == 'player':
		emit_signal("gem_grabbed")
		effect.start()
		

func _on_effect_tween_completed(object, key):
	queue_free()
