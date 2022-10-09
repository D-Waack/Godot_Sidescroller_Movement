extends Area2D

var damage_value = 20

func _on_Spike_body_entered(body):
	if body.has_method("damage"):
		body.damage(damage_value)
