extends Node2D

var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var checkFile = File.new()
	if(checkFile.file_exists("res://save/save_mission.dat")):
		$LoadGame.visible = true
	var _anim_player = $SceneTranstion/AnimationPlayer
	_anim_player.play_backwards("fade")
	yield(_anim_player, "animation_finished")

func _on_NewGame_pressed():
	var _anim_player = $SceneTranstion/AnimationPlayer
	_anim_player.play("fade")
	yield(_anim_player, "animation_finished")
	get_tree().change_scene("res://Pre-main.tscn")
	
func _on_LoadGame_pressed():
	var _anim_player = $SceneTranstion/AnimationPlayer
	_anim_player.play("fade")
	yield(_anim_player, "animation_finished")
	GlobalLoad.loadBool = true
	get_tree().change_scene("res://Main.tscn")
