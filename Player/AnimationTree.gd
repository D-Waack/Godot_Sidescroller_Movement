extends AnimationTree

var animator = self["parameters/playback"]

# Returns the name of the current animation
func get_current():
	return animator.get_current_node()

# Starts the next animation 
func travel(animation : String):
	animator.travel(animation)
