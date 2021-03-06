extends Area2D

var xmin = 0
var sizex = 268

var rand = randomize()
var missionAccepted = false
var initialX_textureRect
var npcList = []
var successChancePercent = 0
onready var initialTimerIgnore = $TimerIgnore.wait_time
var isWin = 1
var modifEquilibrage_money = [0.5,0.5]
var modifEquilibrage_reputation = [0.2,0.3]
var modifEquilibrage_compromised = [0.25,0.25]

export var file_name = ""
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
export var del_NPC_chance = 100
export var nextMission = ["","","",""]
export var clear_board_on_complete = false
export var prerequis_npc=""
export var prerequis_reputation=-1

var speed = -450

signal disappear
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
func _process(delta):
	if(position.x > xmin):
		position.x += speed*delta
	else:
		position.x = xmin
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
	$Filter.visible = true
	if failable:
		var roll = randf()*100.0
		#print("roll="+str(roll)+" VS %chance="+str(successChancePercent))
		if roll<=successChancePercent:
			$AnimationPlayer.play("appear_success")
			yield($AnimationPlayer,"animation_finished")
			isWin = 0
		else:
			$AnimationPlayer.play("appear_failure")
			yield($AnimationPlayer,"animation_finished")
			isWin = 1
	else:
		$AnimationPlayer.play("appear_success")
		yield($AnimationPlayer,"animation_finished")
		isWin = 0
	emit_signal("missionTimeOut", self)

func _on_TimerIgnore_timeout():
	$Filter.visible = true
	$AnimationPlayer.play("appear_failure")
	yield($AnimationPlayer,"animation_finished")
	isWin = 1
	emit_signal("ignoreTimeOut",self)

func _on_detection_npc_area_entered(area):
	if(area.get_parent() is KinematicBody2D):
		emit_signal("NPCEnter", self)

func _on_detection_npc_area_exited(area):
	if(area.get_parent() is KinematicBody2D):
		emit_signal("NPCExit", self)

func modSuccess(npc):
	var mod = 0.5
	if npc.NPC_type==missionType or npc.NPC_type=="You":
		mod =1
	return round(mod * 80/nb_npc)
	
func affect_npc(npc):
	$Stapple.play()
	if npc.NPC_name=="Johnathan":
		$NeedJohnathan.visible=false
	var l = len(npcList)
	if(l < nb_npc):
		if (l <= 2):
			npc.pickable = false
			npc.get_node("pickableFilter").visible = true
			npcList.append(npc)
			get_node("NPCRect/NPC"+str(l+1)).texture = load("res://Assets/portraits/"+npc.NPC_name.to_lower()+"_pixelized_mission.png")		
			successChancePercent += modSuccess(npc)
			$SuccessChance.text="Success chance: "+str(successChancePercent)+"%"
			if needJohnathan:
				for perso in npcList:
					if perso.NPC_name=="Johnathan":
						missionAccepted = true
						$TimerIgnore.stop()
						$TimerMission.start()
				if missionAccepted==false:
					$NeedJohnathan.visible=true
			else:
				$NeedJohnathan.visible = false
				missionAccepted = true
				$TimerIgnore.stop()
				$TimerMission.start()
		else:
			print("ERROR AFFECT_NPC")

func delete_on_ignoreTimeOut():
	makeNPC_pickable()
	emit_signal("disappear")
	call_deferred("queue_free")

func delete_on_missionTimeOut():
	makeNPC_pickable()
	var money_increment = round(modifEquilibrage_money[isWin]*round(outcomeMoney[isWin]*(0.9+randf()*0.2)))
	var reputation_increment = round(modifEquilibrage_reputation[isWin]*round(outcomeReputation[isWin]*(0.9+randf()*0.2)))
	var compromised_increment = round(modifEquilibrage_compromised[isWin]*round(outcomeCompromised[isWin]*(0.9+randf()*0.2)))
	emit_signal("missionAccomplished",money_increment,reputation_increment,compromised_increment)
	call_deferred("queue_free")
	
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
		if l==1:
			$SuccessChance.text = "Success chance: 0%"
			successChancePercent=0
			$NeedJohnathan.visible = false
		else:
			successChancePercent -= modSuccess(npc)
			$SuccessChance.text="Success chance: "+str(successChancePercent)+"%"
		if(len(npcList) == 0):
			$TimerMission.stop()
			$TimerIgnore.start()
			missionAccepted = false
		else:
			$TimerMission.stop()
			$TimerMission.start()

func update_npcs():
	for i in range(0,len(npcList)):
		#get_node("NPCRect/NPC"+str(i+1)).texture = npcList[i].get_node("Sprite").texture
		get_node("NPCRect/NPC"+str(i+1)).texture = load("res://Assets/portraits/"+npcList[i].NPC_name.to_lower()+"_pixelized_mission.png")
	for i in range(len(npcList),nb_npc):
		#get_node("NPCRect/NPC"+str(i+1)).texture = load("res://Assets/icons/person.png")
		get_node("NPCRect/NPC"+str(i+1)).texture = load("res://Assets/icons/person_pixelized.png")
