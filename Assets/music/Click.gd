extends AudioStreamPlayer

func _input(event):
	if event is InputEventMouseButton:
		var index = event.button_index
		var wheel
		match index:
			BUTTON_WHEEL_DOWN:
				wheel = true
			BUTTON_WHEEL_UP:
				wheel = true
			BUTTON_WHEEL_LEFT:
				wheel = true
			BUTTON_WHEEL_RIGHT:
				wheel = true
			_:
				wheel = false
		if (event.is_pressed() and !(wheel)):
			self.play()
	elif event is InputEventKey:
		if (event.is_pressed()):
			self.play()
