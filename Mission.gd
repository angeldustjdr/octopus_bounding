extends RigidBody2D

var rand = randomize()
var missionAccepted = false
var initialX_textureRect
var npcList = []

export var nb_npc = 1
export var outcomeMoney = [0,0]
export var outcomeReputation = [0,0]
export var outcomeCompromised = [0,0]
export var missionType = "?"
var isWin = 1

var speed = -400

signal ignoreTimeOut(mission_id)

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
func _process(_delta):
	linear_velocity.x = speed
#Timer 
	if missionAccepted==false:
		$TimeLabel.text = str($TimerIgnore.time_left)
		$TimeLabel/TextureRect.rect_size.x = initialX_textureRect * $TimerIgnore.time_left/$TimerIgnore.wait_time
	else:
		$TimeLabel.text = str($TimerMission.time_left)
		$TimeLabel/TextureRect.rect_size.x = initialX_textureRect * $TimerMission.time_left/$TimerMission.wait_time

func _on_TimerMission_timeout():
	var successChance = 50
	for npc in npcList:
		if npc.NPC_type == "You" or npc.NPC_type == missionType:
			successChance += 30 / npcList.size()
		else:
			successChance -= 20 / npcList.size()
	var roll = rand.randf_range(0, 100.0)
	if roll<=successChance:
		isWin = 0
	else:
		isWin = 1

func _on_TimerIgnore_timeout():
	emit_signal("ignoreTimeOut",self)
