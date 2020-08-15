extends Node

var rand = randomize()
var missionAccepted = false
var initialX_textureRect

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
	$TimerIgnore.start()
	initialX_textureRect = $TimeLabel/TextureRect.rect_size.x 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#Timer 
	if missionAccepted==false:
		$TimeLabel.text = str($TimerIgnore.time_left)
		$TimeLabel/TextureRect.rect_size.x = initialX_textureRect * $TimerIgnore.time_left/$TimerIgnore.wait_time
	else:
		$TimeLabel.text = str($TimerMission.time_left)
		$TimeLabel/TextureRect.rect_size.x = initialX_textureRect * $TimerMission.time_left/$TimerMission.wait_time

