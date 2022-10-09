extends Area2D

export (float) var damage_value = 40.0

func _on_Spike_body_entered(body):
	if body.has_method("damage"):
		body.damage(damage_value)
