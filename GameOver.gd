extends Node2D

onready var time = 0

func _ready():
	var _anim_player = $SceneTranstion/AnimationPlayer
	_anim_player.play_backwards("fade")
	yield(_anim_player, "animation_finished")

func _process(delta):
	time += delta
	$reasonLabel.modulate.a = abs(sin(time))
	
func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			var _anim_player = $SceneTranstion/AnimationPlayer
			_anim_player.play("fade")
			yield(_anim_player, "animation_finished")
			get_tree().change_scene("res://Titre.tscn")

