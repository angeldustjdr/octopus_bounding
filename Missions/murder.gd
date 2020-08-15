extends RichTextLabel

var cible = ["politician","CEO","engineer","journalist","lawyer","judge","business owner","rich heir"]

# Called when the node enters the scene tree for the first time.
func _ready():
	cible.shuffle()
	self.text = "This "+cible[0]+" must die... Better be quick and silent."


