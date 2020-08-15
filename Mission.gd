extends Node

var rand = randomize()
export var nb_npc = 1
var missionAccepted = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var maxNPC = [$ColorRect/NPC1,$ColorRect/NPC2,$ColorRect/NPC3]
	for i in range(nb_npc):
		maxNPC[i].visible = true
	if missionAccepted==false:
		$TimeLabel.text = str($TimerIgnore.wait_time)
	else:
		$TimeLabel.text = str($TimerMission.wait_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
