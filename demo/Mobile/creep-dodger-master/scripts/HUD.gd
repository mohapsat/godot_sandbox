extends CanvasLayer

signal start_game

onready var score_label = $ScoreLabel
onready var message_label = $MessageLabel
onready var message_timer = $MessageTimer
onready var start_button = $StartButton

func show_message(text):
	message_label.text = text
	message_label.show()
	message_timer.start()

func show_game_over():
    show_message("Game Over")
    yield(message_timer, "timeout")
    start_button.show()
    message_label.text = "Dodge the\nCreeps!"
    message_label.show()
	
func update_score(score):
    score_label.text = str(score)

func _on_MessageTimer_timeout():
	message_label.hide()

func _on_StartButton_pressed():
	start_button.hide()
	emit_signal("start_game")