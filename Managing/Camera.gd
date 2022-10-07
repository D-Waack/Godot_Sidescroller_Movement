extends Camera2D

# Simple camera limits so that the camera cannot leave the prototype area
func _ready():
	limit_top = 0
	limit_bottom = 240
	limit_left = 0
