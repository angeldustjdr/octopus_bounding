extends RichTextLabel

var object = ["watch","handbag","jewlery","perfume","painting","hair clamp"]

# Called when the node enters the scene tree for the first time.
func _ready():
	object.shuffle()
	self.text = "Let's sell this fake Buitton "+object[0]+" ! It's easy money !"
