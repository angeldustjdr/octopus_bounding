extends RichTextLabel

var cible = ["politician","judge","senator","pastor","CEO","engineer","chemist","mayor","community leader"]

# Called when the node enters the scene tree for the first time.
func _ready():
	cible.shuffle()
	self.text = "We need to gather information on this "+cible[0]+". This might prove to be useful for future blackmailing."


