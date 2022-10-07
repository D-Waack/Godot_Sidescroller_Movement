extends AnimationTree

var animator = self["parameters/playback"]

func get_current():
	return animator.get_current_node()

func travel(animation : String):
	animator.travel(animation)
