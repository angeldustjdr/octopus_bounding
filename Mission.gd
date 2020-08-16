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
export var failable = true
export var needJohnathan = false

var speed = -400

signal ignoreTimeOut(mission_id)
signal missionTimeOut(mission_id)
signal NPCEnter(mission_id)
signal NPCExit(mission_id)
signal missionAccomplished(money,reput,compro)

# Called when the node enters the scene tree for the first time.
func _ready():
	#Set NPC socket
	var maxNPC = [$NPCRect/NPC1,$NPCRect/NPC2,$NPCRect/NPC3]
	for i in range(nb_npc):
		maxNPC[i].visible = true
	#Set Mission type label
	$Type_label.text = "Type: "+missionType
	match missionType:
		"Brawl":
			$Type_label.set("custom_colors/font_color",Color(1,0,0))
		"Wit":
			$Type_label.set("custom_colors/font_color",Color(0,0,1))
	$TimerIgnore.start()
	initialX_textureRect = $TimeLabel/TextureRect.rect_size.x 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	linear_velocity.x = speed
#Timer 
	if missionAccepted==false:
		$TimeLabel.text = str($TimerIgnore.time_left)
		$TimeLabel/TextureRect.color = Color(0, 0, 0, 0.3)
		$TimeLabel.set("custom_colors/font_color", Color(1,1,1))
		$TimeLabel/TextureRect.rect_size.x = initialX_textureRect * $TimerIgnore.time_left/$TimerIgnore.wait_time
	else:
		$TimeLabel.text = str($TimerMission.time_left)
		$TimeLabel/TextureRect.color = Color(1, 1, 1, 0.3)
		$TimeLabel.set("custom_colors/font_color", Color(0,0,0))
		$TimeLabel/TextureRect.rect_size.x = initialX_textureRect * $TimerMission.time_left/$TimerMission.wait_time

func _on_TimerMission_timeout():
	if failable:
		var successChance = 50
		for npc in npcList:
			if npc.NPC_type == "You" or npc.NPC_type == missionType:
				successChance += 30 / npcList.size()
			else:
				successChance -= 30 / npcList.size()
		var roll = randf()*100.0
		if roll<=successChance:
			isWin = 0
		else:
			isWin = 1
	else:
		isWin = 0
	emit_signal("missionTimeOut", self)

func _on_TimerIgnore_timeout():
	emit_signal("ignoreTimeOut",self)

func _on_detection_npc_area_entered(area):
	if(area.get_parent() is KinematicBody2D):
		emit_signal("NPCEnter", self)

func _on_detection_npc_area_exited(area):
	if(area.get_parent() is KinematicBody2D):
		emit_signal("NPCExit", self)

func affect_npc(npc):
	var l = len(npcList)
	if(l < nb_npc):
		if (l <= 2):
			npc.pickable = false
			npc.get_node("pickableFilter").visible = true
			npcList.append(npc)
			get_node("NPCRect/NPC"+str(l+1)).texture = load("res://Assets/portraits/"+npc.NPC_name.to_lower()+"_pixelized_mission.png")
			$TimerIgnore.stop()
			if (l+1 < nb_npc):
				$TimerIgnore.start()
			elif (l+1 == nb_npc):
				missionAccepted = true
				$TimerMission.start()
		else:
			print("ERROR AFFECT_NPC")

func delete_on_ignoreTimeOut():
	makeNPC_pickable()
	queue_free()

func delete_on_missionTimeOut():
	makeNPC_pickable()
	emit_signal("missionAccomplished",round(outcomeMoney[isWin]*(0.9+randf()*0.2)),round(outcomeReputation[isWin]*(0.9+randf()*0.2)),round(outcomeCompromised[isWin]*(0.9+randf()*0.2)))
	queue_free()
	
func makeNPC_pickable():
	for npc in npcList:
		npc.pickable = true
		npc.get_node("pickableFilter").visible = false

func _on_collision_NPC1_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				unaffect_npc(0)

func _on_collision_NPC2_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				unaffect_npc(1)

func _on_collision_NPC3_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				unaffect_npc(2)

func unaffect_npc(num):
	var l = len(npcList)
	if (num < l):
		var npc = npcList[num]
		npc.pickable = true
		npc.get_node("pickableFilter").visible = false
		npcList.remove(num)
		update_npcs()
		$TimerMission.stop()
		$TimerIgnore.start()
		missionAccepted = false

func update_npcs():
	for i in range(0,len(npcList)):
		#get_node("NPCRect/NPC"+str(i+1)).texture = npcList[i].get_node("Sprite").texture
		get_node("NPCRect/NPC"+str(i+1)).texture = load("res://Assets/portraits/"+npcList[i].NPC_name.to_lower()+"_pixelized_mission.png")
	for i in range(len(npcList),nb_npc):
		#get_node("NPCRect/NPC"+str(i+1)).texture = load("res://Assets/icons/person.png")
		get_node("NPCRect/NPC"+str(i+1)).texture = load("res://Assets/icons/person_pixelized.png")
