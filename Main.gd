extends Node

var day = 1
var money = 0
var reputation = 100000
var compromised = 0
export var mission_velocity = Vector2(-400,0)
#export var mission_starting_point = Vector2(1280+0.5*268,136+0.5*552)
var mission_offset = Vector2(-10.009,-83.992)
var mission_starting_point = Vector2(1280,136)
var missions = []
var levels = []
export var ignore_reputation_decrease_factor = 5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	update_GUI()
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
	var number = randi() % 5 + 1
	var Mission = load("res://Missions/random"+str(level)+str(number)+".tscn")
	var mission = Mission.instance()
	mission.position.x = mission_starting_point.x + mission_offset.x
	mission.position.y = mission_starting_point.y + mission_offset.y
	#mission.linear_velocity.x = -400
	add_child(mission)
	missions.append(mission)
	mission.connect("ignoreTimeOut", self, "_on_MissionIgnore_timeout")

func _on_MissionTimer_timeout():
	if(len(missions) < 4):
		var rand_level = randi() % 3
		instance_new_mission(rand_level)

func _on_MissionIgnore_timeout(mission):
	var index = missions.find(mission)
	reputation -= (levels[index]+1)*ignore_reputation_decrease_factor
	update_GUI()
	missions.remove(index)
	levels.remove(index)
	mission.queue_free()
