extends Timer

var rand = randomize()



func _on_MissionTimer_timeout():
	self.wait_time = 0.8 + randf()
