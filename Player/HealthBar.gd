extends Control

onready var health_bar = $TrueBar
onready var slow_bar = $SlowBar

func update_health(health):
	health_bar.value = health
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(slow_bar, "value", health, 0.6)
	

func updated_max_health(max_health):
	health_bar.max_value = max_health
	slow_bar.max_value = max_health
