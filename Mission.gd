extends Node

var rand = randomize()
var missionAccepted = false

export var nb_npc = 1
export var outcomeMoney = [0,0]
export var outcomeReputation = [0,0]
export var outcomeCompromised = [0,0]
export var missionType = "?"
var isWin = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#Set NPC socket
	var maxNPC = [$ColorRect/NPC1,$ColorRect/NPC2,$ColorRect/NPC3]
	for i in range(nb_npc):
		maxNPC[i].visible = true
	#Set Mission type label
	$Type_label.text = "Type: "+missionType
	#Set Timer label
	if missionAccepted==false:
		$TimeLabel.text = str($TimerIgnore.wait_time)
	else:
		$TimeLabel.text = str($TimerMission.wait_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

