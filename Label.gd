extends Label

var time = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (visible) :
		time += delta
		modulate.a = 0.5+0.5*sin(3*time)


func _on_Label_draw():
	time = 0
