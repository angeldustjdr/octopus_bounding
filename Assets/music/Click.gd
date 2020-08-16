extends AudioStreamPlayer

func _input(event):
	if event is InputEventMouseButton or event is InputEventKey:
		self.play()
