extends RichTextLabel

var gamble = ["horse","jockey","baseball team","football team","athletic runner","gymnast","boxer","dog","basketball team"]

# Called when the node enters the scene tree for the first time.
func _ready():
	gamble.shuffle()
	self.text = "Let's gamble on this "+gamble[0]+" ! Luck may be on our side !"
