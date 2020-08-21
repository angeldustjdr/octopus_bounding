extends Node

var day = 1
var time = 0
var random = randomize()
var inSequence = true
var inTuto = true
var missionQueue = []
var currentLevel = 0
var difficultyCurve = [0,1,1,2,2,2,2]
var nextSequence = 0
var nbSequence = 0
var saveSequenceBool = false

#SCORE
var money = 0
var reputation = 0
var compromised = 0

#MISSION
var mission_offset = Vector2(-10.009,-83.992)
var mission_starting_point = Vector2(1104,0)
var missions = []
var mission_per_level = [5, 5, 5]
export var ignore_reputation_decrease_factor = 4
var mission_collision_index = []

#NPC
var npc_slot_occupied = [false, false, false, false, false, false, false]
var npcs = []
var npcs_name = []
var current_npc = null

var clicked = false
signal mouse_button_released
signal gameIsPaused(stat)
signal inputKey
signal unPause
var pauseFrameBefore = false
var F2FrameBefore = false
var loadFrameBefore = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$PauseRect.mode = 3
	pauseGame()
	connect("gameIsPaused",$InfoBulleManager,"manage_pause")
	connect("gameIsPaused",get_node("/root/MusicPlayer"),"set_volume_for_pause")
	var _anim_player = $SceneTranstion/AnimationPlayer
	_anim_player.play_backwards("fade")
	yield(_anim_player, "animation_finished")
	pauseGame()
	$PauseRect.mode = 0
	if (GlobalLoad.loadBool): #LOADGAME
		load_save("res://save/save_mission.dat")
	else: #NEWGAME
		$PauseRect.mode = 1
		custom_pause(false,"Tutorial","","")
		pauseGame()
		yield(self,"unPause")
		reset_pause()
		$PauseRect.mode = 0
		missionQueue = ["tuto01"]
		load_NPC("johnathan")
		save("res://save/save_sequence.dat")
		save("res://save/save_mission.dat")
	$MissionTimer.start()
	update_GUI()

func update_GUI():
	get_node("GameArea/TimeArea/TimeLabel").text = "Day " + str(day)
	get_node("GameArea/ScoreArea/Money/Money_label").text = str(money)
	get_node("GameArea/ScoreArea/Reputation/Reputation_label").text = str(reputation) +"%"
	get_node("GameArea/ScoreArea/Compromised/Compromised_label").text = str(compromised) + "%"

func _process(delta):
	for mis in missionQueue:
		if !("tuto" in mis):
			$Skip2.shining=false
			$Skip2.visible=false
		else:
			$Skip2.visible=true
			$Skip2.shining=true
	time += delta
	if money < -80:
		get_node("GameArea/ScoreArea/Money/Money_label").set("custom_colors/font_color",Color(1,0,0))
		get_node("GameArea/ScoreArea/Money/Money_label").modulate.a=abs(sin(time))
	else:
		get_node("GameArea/ScoreArea/Money/Money_label").set("custom_colors/font_color",Color(1,1,1))
		get_node("GameArea/ScoreArea/Money/Money_label").modulate.a=1
	if reputation < 20:
		get_node("GameArea/ScoreArea/Reputation/Reputation_label").set("custom_colors/font_color",Color(1,0,0))
		get_node("GameArea/ScoreArea/Reputation/Reputation_label").modulate.a=abs(sin(time))
	else:
		get_node("GameArea/ScoreArea/Reputation/Reputation_label").set("custom_colors/font_color",Color(1,1,1))
		get_node("GameArea/ScoreArea/Reputation/Reputation_label").modulate.a=1
	if compromised > 80:
		get_node("GameArea/ScoreArea/Compromised/Compromised_label").set("custom_colors/font_color",Color(1,0,0))
		get_node("GameArea/ScoreArea/Compromised/Compromised_label").modulate.a=abs(sin(time))
	else:
		get_node("GameArea/ScoreArea/Compromised/Compromised_label").set("custom_colors/font_color",Color(1,1,1))
		get_node("GameArea/ScoreArea/Compromised/Compromised_label").modulate.a=1

func instance_new_mission(myMission):
	var Mission = load("res://Missions/"+myMission+".tscn")
	var mission = Mission.instance()
	var missionAvailableNPC=false
	var missionAvailableReputation=false
	if mission.prerequis_npc=="":
		missionAvailableNPC = true
	else:
		for perso in npcs:
			if perso.NPC_name.to_lower()==mission.prerequis_npc.to_lower():
				if(perso.available):
					missionAvailableNPC = true
	if reputation>mission.prerequis_reputation:
			missionAvailableReputation = true
	if missionAvailableNPC==false or missionAvailableReputation==false:
		mission.get_node("UnavailableRect").visible = true
		mission.get_node("detection_npc/CollisionShape2D2").disabled = true
	mission.get_node("TimerIgnore").wait_time *= 1.2 + randf()*0.2
	#mission.get_node("TimerIgnore").wait_time *= 0.2
	mission.position.x = mission_starting_point.x + mission_offset.x
	mission.position.y = mission_starting_point.y + mission_offset.y
	$Audio.stream = load("res://Assets/music/type_writer.wav")
	$Audio.play()
	$MissionRect.add_child(mission)
	missions.append(mission)
	mission.connect("ignoreTimeOut", self, "_on_MissionIgnore_timeout")
	mission.connect("missionTimeOut", self, "_on_Mission_timeout")
	mission.connect("NPCEnter", self, "set_current_mission_collision")
	mission.connect("NPCExit", self, "reset_current_mission_collision")
	mission.connect("missionAccomplished", self, "update_score")

func _on_MissionTimer_timeout():
	if inSequence==false:
		missionQueue.append("random"+str(difficultyCurve[currentLevel])+str(1+randi()%mission_per_level[difficultyCurve[currentLevel]]))
		if(len(missions) < 4):
			if missionQueue.size()>0:
				instance_new_mission(missionQueue[0])
				missionQueue.remove(0)
		inTuto = false
	else:
		if missionQueue.size()>0:
			if "random" in missionQueue[0]:
				instance_new_mission(missionQueue[0])
				missionQueue.remove(0)
			else:
				var wait = false
				for mis in missions:
					if mis.missionType=="Brawl" or mis.missionType=="Wit":
						wait = true
				if wait==false:
					instance_new_mission(missionQueue[0])
					missionQueue.remove(0)

func _on_MissionIgnore_timeout(mission):
	var index = missions.find(mission)
	update_GUI()
	$Audio.stream = load("res://Assets/music/burning.ogg")
	$Audio.play()
	missions.remove(index)
	$MissionTimer.set_paused(true)
	var anim = mission.get_node("AnimationPlayer")
	anim.play("disappear")
	yield(anim,"animation_finished")
	$MissionTimer.set_paused(false)
	mission.delete_on_missionTimeOut()

func _on_Mission_timeout(mission):
	if mission.add_NPC_on_complete != "":
		load_NPC(mission.add_NPC_on_complete)
	if mission.del_NPC_on_complete != "":
		var index = npcs_name.find(mission.del_NPC_on_complete)
		if(index != -1):
			if(randf()*100 <= mission.del_NPC_chance):
				npcs[index].make_not_available()
	for next in mission.nextMission:
		if next=="end_sequence":
			inSequence = false
			for i in range(4):
				missionQueue.append("random"+str(difficultyCurve[currentLevel])+str(1+randi()%mission_per_level[difficultyCurve[currentLevel]]))
		elif "end_game" in next:
			var _anim_player = $SceneTranstion/AnimationPlayer
			_anim_player.play("fade")
			yield(_anim_player, "animation_finished")
			get_tree().change_scene("res://Missions/"+next+".tscn")
		else:
			if next != "":
				missionQueue.append(next)
	var index = missions.find(mission)
	$Audio.stream = load("res://Assets/music/burning.ogg")
	$Audio.play()
	day += 1
	if mission.clear_board_on_complete == true:
		$MissionTimer.set_paused(true)
		var anim
		for mis in missions:
			anim = mis.get_node("AnimationPlayer")
			anim.play("disappear")
		yield(anim,"animation_finished")
		$MissionTimer.set_paused(false)
		for mis in missions:
			mis.delete_on_missionTimeOut()
			missions = []
	else:
		$MissionTimer.set_paused(true)
		var anim = mission.get_node("AnimationPlayer")
		anim.play("disappear")
		yield(anim,"animation_finished")
		$MissionTimer.set_paused(false)
		missions.remove(index)
		mission.delete_on_missionTimeOut()
	if inSequence==false:
		nextSequence+=1
		if nextSequence>=3:
			inSequence=true
			nextSequence=0
			nbSequence+=1
			currentLevel+=1
			missionQueue=["act"+str(nbSequence)+"_01"]
			saveSequenceBool = true
	if(len(missions) == 0 and saveSequenceBool):
		if (nbSequence <= 6):
			save("res://save/save_sequence.dat")
			$PauseRect.mode = 1
			custom_pause(false,"Act " + str(nbSequence),"","")
			pauseGame()
			yield(self,"unPause")
			reset_pause()
			$PauseRect.mode = 0
		saveSequenceBool = false
	save("res://save/save_mission.dat")
	update_GUI()


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
	var anim = npc.get_node("AnimationPlayer")
	anim.play("NPCenter")
	yield(anim,"animation_finished")
	
func load_NPC_without_animation(name):
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
	var anim = npc.get_node("AnimationPlayer")
	anim.set_current_animation("NPCenter")
	anim.advance(anim.current_animation_length)
	
func unload_NPC_without_animation(num):
	npc_slot_occupied[num] = true
	npcs_name.remove(num)
	npcs[num].call_deferred("queue_free")
	npcs.remove(num)

func _input(event):
	if(event is InputEventMouseButton):
		emit_signal("inputKey")
		if (event.button_index == BUTTON_LEFT and event.pressed):
			clicked = true
		elif(event.button_index == BUTTON_LEFT and !event.pressed):
			if(clicked):
				emit_signal("mouse_button_released")
				clicked = false
	elif(event is InputEventKey):
		emit_signal("inputKey")
		match event.scancode:
			KEY_ESCAPE:
				if(event.pressed):
					if(!pauseFrameBefore):
						pauseFrameBefore = true
						pauseGame()
				else:
					pauseFrameBefore = false
			KEY_SPACE:
				if(event.pressed):
					if(!pauseFrameBefore):
						pauseFrameBefore = true
						pauseGame()
				else:
					pauseFrameBefore = false
		if(!get_tree().paused):
			match event.scancode:
				KEY_F1:
					if (event.pressed):
						if(!loadFrameBefore):
							loadFrameBefore = true
							load_save("res://save/save_sequence.dat")
							save_mission_equal_save_sequence()
					else:
						loadFrameBefore = false
				KEY_F2:
					if(inTuto):
						if (event.pressed):
							if(!F2FrameBefore):
								F2FrameBefore = true
								load_save("res://config/after_tuto.dat")
						else:
							F2FrameBefore = false

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
			for mis in missions:
				if mis != m and mis.missionAccepted==false:
					var timeLeft = mis.get_node("TimerIgnore").time_left
					if timeLeft>10:
						changeTime(mis,timeLeft)
		else:
			print("ERROR MAGGLE")
	current_npc = null

func changeTime(mis,timeLeft):
	mis.get_node("TimerIgnore").start(timeLeft-10)
	mis.get_node("TimerChangeLabel").visible=true
	var player = mis.get_node("TimerChangeLabel/AnimationPlayer")
	player.play("timeChange")
	yield(player, "animation_finished")
	mis.get_node("TimerChangeLabel").visible=false

func set_current_npc(npc):
	current_npc = npc

func update_score(money_incr,reput_incr,compro_incr):
	anminateOutcome(money_incr,"money")
	anminateOutcome(reput_incr,"reputation")
	anminateOutcome(compro_incr,"compromised")
	money += money_incr
	reputation += reput_incr
	reputation = min(reputation,100)
	compromised += compro_incr
	update_GUI()
	check_gameover()

func anminateOutcome(value,myString):
	var Sign = ""
	if value>0:
		Sign="+"
	if value!=0:
		if myString=="money":
			$GameArea/updateMoney.text = Sign+str(value)
			$GameArea/updateMoney.visible=true
			$GameArea/animationMoneyUpdate.play("moneyUpdate")
			yield($GameArea/animationMoneyUpdate, "animation_finished")
			$GameArea/updateMoney.visible=false
		if myString=="reputation":
			$GameArea/updateReputation.text = Sign+str(value)
			$GameArea/updateReputation.visible=true
			$GameArea/animationReputationUpdate.play("reputationUpdate")
			yield($GameArea/animationReputationUpdate, "animation_finished")
			$GameArea/updateReputation.visible=false
		if myString=="compromised":
			$GameArea/updateCompromised.text = Sign+str(value)
			$GameArea/updateCompromised.visible=true
			$GameArea/animationCompromisedUpdate.play("compromisedUpdate")
			yield($GameArea/animationCompromisedUpdate, "animation_finished")
			$GameArea/updateCompromised.visible=false

func check_gameover():
	$PauseRect.mode = 2
	if (money < -100):
		get_node("/root/MusicPlayer/Gunshot").play()
		custom_pause(false,"You failed.","","You got shot by your creditors.")
		pauseGame()
		yield(self,"unPause")
		gameover()
	elif (reputation < 0):
		get_node("/root/MusicPlayer/Gunshot").play()
		custom_pause(false,"You failed.","","You got shot by the mafia because of your bad reputation.")
		pauseGame()
		yield(self,"unPause")
		gameover()
	elif (compromised > 100):
		get_node("/root/MusicPlayer/Jaildoor").play()
		custom_pause(false,"You failed.","","You got busted.")
		pauseGame()
		yield(self,"unPause")
		gameover()

func gameover():
	#var _anim_player = $SceneTranstion/AnimationPlayer
	#_anim_player.play("fade")
	#yield(_anim_player, "animation_finished")
	GlobalLoad.loadBool = false
	save_mission_equal_save_sequence()
	get_tree().change_scene("res://GameOver.tscn")

func pauseGame():
	match $PauseRect.mode:
		0:
			emit_signal("gameIsPaused",!get_tree().paused)
			if (!get_tree().paused):
				$PauseRect/AnimationPlayer.play("appear")
			else:
				$PauseRect/AnimationPlayer.play_backwards("appear")
			$PauseRect/disableGame.visible = !get_tree().paused
			get_tree().paused = !get_tree().paused
			yield($PauseRect/AnimationPlayer, "animation_finished")
		1:
			emit_signal("gameIsPaused",true)
			$PauseRect/disableGame.visible = true
			get_tree().paused = true
			$PauseRect/AnimationPlayer.play("appear")
			yield($PauseRect/AnimationPlayer, "animation_finished")
			yield(self,"inputKey")
			$PauseRect/AnimationPlayer.play_backwards("appear")
			yield($PauseRect/AnimationPlayer, "animation_finished")
			emit_signal("gameIsPaused",false)
			emit_signal("unPause")
			$PauseRect/disableGame.visible = false
			get_tree().paused = false
		2:
			emit_signal("gameIsPaused",true)
			$PauseRect/disableGame.visible = true
			get_tree().paused = true
			$PauseRect/AnimationPlayer.play("appear")
			yield($PauseRect/AnimationPlayer, "animation_finished")
			yield(self,"inputKey")
			var _anim_player = $SceneTranstion/AnimationPlayer
			_anim_player.play("fade")
			yield(_anim_player, "animation_finished")
			emit_signal("gameIsPaused",false)
			emit_signal("unPause")
			$PauseRect/disableGame.visible = false
			get_tree().paused = false
		3:
			emit_signal("gameIsPaused",!get_tree().paused)
			get_tree().paused = !get_tree().paused

func save(file_name):
	#print("SAVE")
	var saveFile = File.new()
	var err = saveFile.open(file_name, File.WRITE)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var line = str(money) +","+str(reputation)+','+str(compromised)+","+str(day)
	saveFile.store_line(line)
	saveFile.store_line(str(int(inTuto)))
	saveFile.store_line(str(int(inSequence)))
	saveFile.store_line(str(currentLevel))
	saveFile.store_line(str(nextSequence))
	saveFile.store_line(str(nbSequence))
	line = npcs_name[0]
	var inter = str(int(npcs[0].available))
	for i in range(1,len(npcs_name)):
		line += ","+npcs_name[i]
		inter += ","+str(int(npcs[i].available))
	saveFile.store_line(line)
	saveFile.store_line(inter)
	if (len(missionQueue) > 0):
		line = missionQueue[0]
		for i in range(1,len(missionQueue)):
			line += ","+missionQueue[i]
		saveFile.store_line(line)
	else:
		saveFile.store_line("")
	if len(missions)>0:
		line = missions[0].file_name
		var lim = min(4,len(missions))
		for i in range(1,lim):
			line += ","+missions[i].file_name
	else:
		line = ""
	saveFile.store_line(line)
	saveFile.close()
	
func load_save(file_name):
	$MissionTimer.set_paused(true)
	clean_mission_board()
	clean_NPC_board()
	missionQueue = []
	var loadedFile = File.new()
	var err = loadedFile.open(file_name, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var line = loadedFile.get_line()
	line = line.split(",")
	money = int(line[0])
	reputation = int(line[1])
	compromised = int(line[2])
	day = int(line[3])
	update_GUI()
	line = loadedFile.get_line()
	inTuto = bool(int(line))
	line = loadedFile.get_line()
	inSequence = bool(int(line))
	line = loadedFile.get_line()
	currentLevel = int(line)
	line = loadedFile.get_line()
	nextSequence = int(line)
	line = loadedFile.get_line()
	nbSequence = int(line)
	line = loadedFile.get_line()
	line = line.split(",")
	for i in range(0,len(line)):
		#load_NPC_without_animation(name)
		load_NPC(line[i])
	yield(npcs[-1].get_node("AnimationPlayer"),"animation_finished")
	line = loadedFile.get_line()
	line = line.split(",")
	for i in range(0,len(line)):
		if(!bool(int(line[i]))):
			npcs[i].make_not_available()
	line = loadedFile.get_line()
	line = line.split(",")
	if (line[0] != ""):
		for mQ in line:
			missionQueue.append(mQ)
	line = loadedFile.get_line()
	loadedFile.close()
	if (line != ""):
		line = line.split(",")
		var t = Timer.new()
		t.set_wait_time($MissionTimer.wait_time)
		t.set_one_shot(true)
		add_child(t)
		for li in line:
			instance_new_mission(li.to_lower())
			t.start()
			yield(t,"timeout")
	$MissionTimer.set_paused(false)

func clean_mission_board():
	for mis in missions:
		mis.delete_on_ignoreTimeOut()
	missions = []
	
func clean_NPC_board():
	for i in range(len(npcs)-1,-1,-1):
		unload_NPC_without_animation(i)

func reset_pause():
	$PauseRect/PauseLabel.shining = true
	$PauseRect/PauseLabel.text = "PAUSE"
	$PauseRect/Load.text = "You can press F1 to load the previous act."
	$PauseRect/Skip.text = "You can press F2 to skip the tutorial."

func custom_pause(shi, pause_text,load_text,skip_text):
	$PauseRect/PauseLabel.shining = shi
	$PauseRect/PauseLabel.text = pause_text
	$PauseRect/Load.text = load_text
	$PauseRect/Skip.text = skip_text

func save_mission_equal_save_sequence():
	var save_seq = File.new()
	var save_mis = File.new()
	save_seq.open("res://save/save_sequence.dat", File.READ)
	save_mis.open("res://save/save_mission.dat", File.WRITE)
	var save_seq_str = save_seq.get_as_text()
	save_mis.store_string(save_seq_str)
	save_mis.close()
	save_seq.close()
