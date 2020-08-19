extends Label


onready var time=0

func _process(delta):
	time += delta
	self.modulate.a = abs(sin(2*time))
