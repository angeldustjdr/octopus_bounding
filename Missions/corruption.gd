extends RichTextLabel

var cible = ["politician","police officer","judge","jury","senator","mayor","attorney","CEO"]
# Called when the node enters the scene tree for the first time.
func _ready():
	cible.shuffle()
	self.text = "We need to bribe this "+cible[0]+" in order to strengthen our positions."


