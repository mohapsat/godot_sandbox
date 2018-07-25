extends Area2D


func _on_Water_body_entered( body ):
	if body.name == "Frog":
		body.start_swimming()
	pass # replace with function body


func _on_Water_body_exited( body ):
	if body.name == "Frog":
		body.end_swimming()
	
	
	pass # replace with function body
