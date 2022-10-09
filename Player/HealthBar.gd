extends Control

onready var health_bar = $TextureProgress

func update_health(health):
	#health_bar.value = health
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(health_bar, "value", health, 0.5)

func updated_max_health(max_health):
	health_bar.max_value = max_health
