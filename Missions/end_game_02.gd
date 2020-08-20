extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var _anim_player = $SceneTranstion/AnimationPlayer
	_anim_player.play_backwards("fade")
	yield(_anim_player, "animation_finished")



func _input(event):
	if (event is InputEventKey or event is InputEventMouseButton):
		var _anim_player = $SceneTranstion/AnimationPlayer
		_anim_player.play("fade")
		yield(_anim_player, "animation_finished")
		get_tree().change_scene("res://Titre.tscn")
