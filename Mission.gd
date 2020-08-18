extends RigidBody2D

var rand = randomize()
var missionAccepted = false
var initialX_textureRect
var npcList = []
var successChancePercent = 50
onready var initialTimerIgnore = $TimerIgnore.wait_time
var isWin = 1
var modifEquilibrage = 0.5

export var nb_npc = 1
export var outcomeMoney = [0,0]
export var outcomeReputation = [0,0]
export var outcomeCompromised = [0,0]
export var missionType = "?"
export var failable = true
export var needJohnathan = false
export var cantIgnore = false
export var add_NPC_on_complete = ""
export var del_NPC_on_complete = ""
export var nextMission = ["","","",""]
export var clear_board_on_complete = false

var speed = -500

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
	#CONNEXION
	$TimerIgnore.connect("timeout", self, "_on_TimerIgnore_timeout")
	$TimerMission.connect("timeout", self, "_on_TimerMission_timeout")
	$detection_npc.connect("area_entered", self, "_on_detection_npc_area_entered")
	$detection_npc.connect("area_exited", self, "_on_detection_npc_area_exited")
	$NPCRect/NPC1/collision_NPC1.connect("input_event", self, "_on_collision_NPC1_input_event")
	$NPCRect/NPC2/collision_NPC2.connect("input_event", self, "_on_collision_NPC2_input_event")
	$NPCRect/NPC3/collision_NPC3.connect("input_event", self, "_on_collision_NPC3_input_event")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	linear_velocity.x = speed
#Timer 
	if cantIgnore:
		$TimerIgnore.wait_time=1
		$TimerIgnore.stop()
	if missionAccepted==false:
		$TimeLabel.text = str($TimerIgnore.time_left)
		$TimeLabel/TextureRect.color = Color(0, 0, 0, 0.3)
		$TimeLabel.set("custom_colors/font_color", Color(1,1,1))
		$TimeLabel/TextureRect.rect_size.x = initialX_textureRect * $TimerIgnore.time_left/initialTimerIgnore
	else:
		$TimeLabel.text = str($TimerMission.time_left)
		$TimeLabel/TextureRect.color = Color(1, 1, 1, 0.3)
		$TimeLabel.set("custom_colors/font_color", Color(0,0,0))
		$TimeLabel/TextureRect.rect_size.x = initialX_textureRect * $TimerMission.time_left/$TimerMission.wait_time

func _on_TimerMission_timeout():
	if failable:
		var roll = randf()*100.0
		print("roll="+str(roll)+" VS %chance="+str(successChancePercent))
		if roll<=successChancePercent:
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
	if npc.NPC_name=="Johnathan":
		$NeedJohnathan.visible=false
	var Sign = -1
	if npc.NPC_type==missionType or npc.NPC_type=="You":
		Sign=1
	successChancePercent += round(Sign*30/nb_npc)
	$SuccessChance.text="Success chance: "+str(successChancePercent)+"%"
	var l = len(npcList)
	if(l < nb_npc):
		if (l <= 2):
			npc.pickable = false
			npc.get_node("pickableFilter").visible = true
			npcList.append(npc)
			get_node("NPCRect/NPC"+str(l+1)).texture = load("res://Assets/portraits/"+npc.NPC_name.to_lower()+"_pixelized_mission.png")
			if (l+1 == nb_npc):
				if needJohnathan:
					for perso in npcList:
						if perso.NPC_name=="Johnathan":
							missionAccepted = true
							$TimerMission.start()
					if missionAccepted==false:
						$NeedJohnathan.visible=true
				else:
					$NeedJohnathan.visible = false
					missionAccepted = true
					$TimerMission.start()
		else:
			print("ERROR AFFECT_NPC")

func delete_on_ignoreTimeOut():
	makeNPC_pickable()
	emit_signal("disappear")
	queue_free()

func delete_on_missionTimeOut():
	makeNPC_pickable()
	var money_increment = round(modifEquilibrage*round(outcomeMoney[isWin]*(0.9+randf()*0.2)))
	var reputation_increment = round(modifEquilibrage*round(outcomeReputation[isWin]*(0.9+randf()*0.2)))
	var compromised_increment = round(modifEquilibrage*round(outcomeCompromised[isWin]*(0.9+randf()*0.2)))
	emit_signal("missionAccomplished",money_increment,reputation_increment,compromised_increment)
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
		if l==1:
			$SuccessChance.text = "Success chance: 0%"
			successChancePercent=50
			$NeedJohnathan.visible = false
		else:
			var Sign = -1
			if npc.NPC_type==missionType or npc.NPC_type=="You":
				Sign=1
			successChancePercent -= round(Sign*40/nb_npc)
			$SuccessChance.text="Success chance: "+str(successChancePercent)+"%"
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
