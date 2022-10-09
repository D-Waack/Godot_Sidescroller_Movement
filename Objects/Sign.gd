extends Area2D

export (String) var hint_text = ""

signal display_hint

func _on_Sign_body_entered(body):
	if body is Player:
		emit_signal("display_hint", hint_text)

func _on_Sign_body_exited(body):
	if body is Player:
		emit_signal("display_hint", "")
