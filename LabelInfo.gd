extends Label

var infoBulle = ""

func _process(delta):
	if infoBulle == "":
		self.visible = false
	else:
		self.visible = true
		self.rect_position = get_viewport().get_mouse_position() + Vector2(-80,10)
		self.text = infoBulle

func _on_ZoneTitre_mouse_entered():
	infoBulle = "Name of your mission"


func _on_ZoneTitre_mouse_exited():
	infoBulle = ""


func _on_ZoneType_mouse_entered():
	infoBulle = "Type of your mission.\nTry to assign the correct NPC."


func _on_ZoneType_mouse_exited():
	infoBulle = ""


func _on_ZoneDescription_mouse_entered():
	infoBulle = "Description of your mission"
