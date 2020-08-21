extends Label

var time = 0
var shining = true
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (visible):
		if(shining):
			time += delta
			modulate.a = 0.5+0.5*sin(3*time)
		else:
			modulate.a = 1

func _on_Label_draw():
	time = 0
