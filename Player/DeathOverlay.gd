extends Control

onready var panel = $ColorRect

func _ready():
	set_physics_process(false)
	panel.set_visible(false)

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		print("Restart stage !!TODO")

func display_death_panel():
	panel.set_visible(true)
	set_physics_process(true)
