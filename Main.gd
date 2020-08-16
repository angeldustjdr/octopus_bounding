extends Node

var day = 1

#SCORE
var money = 0
var reputation = 0
var compromised = 0

#MISSION
var mission_offset = Vector2(-10.009,-83.992)
var mission_starting_point = Vector2(1104,0)
var missions = []
var levels = []
var mission_per_level = [5, 5, 3]
export var ignore_reputation_decrease_factor = 5
var mission_collision_index = []

#NPC
var npc_slot_occupied = [false, false, false, false, false, false, false]
var npcs = []
var npcs_name = []
var current_npc = null

var clicked = false
signal mouse_button_released

# Called when the node enters the scene tree for the first time.
func _ready():
	var _anim_player = $SceneTranstion/AnimationPlayer
	_anim_player.play_backwards("fade")
	yield(_anim_player, "animation_finished")
	update_GUI()
	load_NPC("alison")
	load_NPC("erica")
	load_NPC("thomas")
	load_NPC("nina")
	$MissionTimer.start()

func update_GUI():
	get_node("GameArea/TimeArea/TimeLabel").text = "Day " + str(day)
	get_node("GameArea/ScoreArea/Money/Money_label").text = str(money)
	get_node("GameArea/ScoreArea/Reputation/Reputation_label").text = str(reputation)
	get_node("GameArea/ScoreArea/Compromised/Compromised_label").text = str(compromised) + "%"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):

func instance_new_mission(level):
	levels.append(level)
	var number = randi() % mission_per_level[level] + 1
	var Mission = load("res://Missions/random"+str(level)+str(number)+".tscn")
	var mission = Mission.instance()
	mission.position.x = mission_starting_point.x + mission_offset.x
	mission.position.y = mission_starting_point.y + mission_offset.y
	$Audio.stream = load("res://Assets/music/mission_enter.ogg")
	$Audio.play()
	$MissionRect.add_child(mission)
	missions.append(mission)
	mission.connect("ignoreTimeOut", self, "_on_MissionIgnore_timeout")
	mission.connect("missionTimeOut", self, "_on_Mission_timeout")
	mission.connect("NPCEnter", self, "set_current_mission_collision")
	mission.connect("NPCExit", self, "reset_current_mission_collision")
	mission.connect("missionAccomplished", self, "update_score")

func _on_MissionTimer_timeout():
	if(len(missions) < 4):
		var rand_level = randi() % 3
		#var rand_level = 0
		instance_new_mission(rand_level)

func _on_MissionIgnore_timeout(mission):
	var index = missions.find(mission)
	update_score(0,-1*(levels[index]+1)*ignore_reputation_decrease_factor,0)
	update_GUI()
	$Audio.stream = load("res://Assets/music/burning.ogg")
	$Audio.play()
	missions.remove(index)
	levels.remove(index)
	mission.delete_on_ignoreTimeOut()

func _on_Mission_timeout(mission):
	var index = missions.find(mission)
	$Audio.stream = load("res://Assets/music/burning.ogg")
	$Audio.play()
	missions.remove(index)
	levels.remove(index)
	mission.delete_on_missionTimeOut()

func load_NPC(name):
	npcs_name.append(name)
	var file_path = "res://PNJ/"+name+".tscn"
	var Current_character = load(file_path)
	var npc = Current_character.instance()
	npcs.append(npc)
	var i_npc = len(npcs) - 1
	var i_position = get_node("NPCArea/node_NPC"+str(i_npc+1)).position
	npc.initial_position.y = i_position.x
	npc.initial_position.y = i_position.y
	npc.position.x = i_position.x
	npc.position.y = i_position.y
	npc_slot_occupied[i_npc] = true
	connect("mouse_button_released",npc,"go_back_to_initial_position")
	npc.connect("dragged",self,"set_current_npc")
	$NPCArea.add_child(npc)

func _input(event):
	if(event is InputEventMouseButton):
		if (event.button_index == BUTTON_LEFT and event.pressed):
			clicked = true
		elif(event.button_index == BUTTON_LEFT and !event.pressed):
			if(clicked):
				emit_signal("mouse_button_released")
				clicked = false

func set_current_mission_collision(mission):
	mission_collision_index.append(mission)
	#print(mission_collision_index)

func reset_current_mission_collision(mission):
	mission_collision_index.erase(mission)
	#print(mission_collision_index)

func affect_current_npc():
	var l = len(mission_collision_index) 
	if (l > 0):
		var m
		if (l > 1):
			m = mission_collision_index[-1]
		else:
			m = mission_collision_index[0]
		if(current_npc != null):
			#print(current_npc.NPC_name)
			m.affect_npc(current_npc)
		else:
			print("ERROR MAGGLE")
	current_npc = null

func set_current_npc(npc):
	current_npc = npc

func update_score(money_incr,reput_incr,compro_incr):
	anminateOutcome(money_incr,"money")
	anminateOutcome(reput_incr,"reputation")
	anminateOutcome(compro_incr,"compromised")
	money += money_incr
	reputation += reput_incr
	compromised += compro_incr
	update_GUI()
	check_gameover()

func anminateOutcome(value,myString):
	var Sign = ""
	if value>0:
		Sign="+"
	if value!=0:
		match myString:
			"money":
				$GameArea/updateMoney.text = Sign+str(value)
				$GameArea/updateMoney.visible=true
				$GameArea/animationUpdate.play("moneyUpdate")
			"reputation":
				$GameArea/updateReputation.text = Sign+str(value)
				$GameArea/updateReputation.visible=true
				$GameArea/animationUpdate.play("reputationUpdate")
			"compromised":
				$GameArea/updateCompromised.text = Sign+str(value)
				$GameArea/updateCompromised.visible=true
				$GameArea/animationUpdate.play("compromisedUpdate")

func check_gameover():
	if (money < -100):
		gameover()
	elif (reputation < 0):
		gameover()
	elif (compromised > 100):
		gameover()

func gameover():
	var _anim_player = $SceneTranstion/AnimationPlayer
	_anim_player.play("fade")
	yield(_anim_player, "animation_finished")
	get_tree().change_scene("res://GameOver.tscn")
