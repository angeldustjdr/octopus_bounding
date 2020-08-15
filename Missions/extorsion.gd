extends RichTextLabel

var commerce = ["restaurant owner","taxi driver","shop owner","grocery store owner","florist","hipster café owner","bakery shop owner"]

# Called when the node enters the scene tree for the first time.
func _ready():
	commerce.shuffle()
	self.text = "This "+commerce[0]+" hasn't payed his due yet. It's take for pay back !"


