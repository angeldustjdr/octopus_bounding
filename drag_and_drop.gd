extends KinematicBody2D

export var initial_position = Vector2(0, 0)
var dragging = false

func _ready():
	initial_position = position
	
func _process(_delta):
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.position = Vector2(mousepos.x, mousepos.y)

func _on_Character_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and !event.pressed:
			go_back_to_initial_position()
			dragging = false
		if event.button_index == BUTTON_LEFT and event.pressed and !dragging:
			dragging = true
				
func go_back_to_initial_position():
	position = initial_position
