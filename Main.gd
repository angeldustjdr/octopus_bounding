extends Node

export var day = 1
export var money = 0
export var reputation = 0
export var compromised = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	update_GUI()

func update_GUI():
	get_node("GameArea/TimeArea/TimeLabel").text = "Day " + str(day)
	get_node("GameArea/ScoreArea/Money/Money_label").text = str(money)
	get_node("GameArea/ScoreArea/Reputation/Reputation_label").text = str(reputation)
	get_node("GameArea/ScoreArea/Compromised/Compromised_label").text = str(compromised) + "%"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
