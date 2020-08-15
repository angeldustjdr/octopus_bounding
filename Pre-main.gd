extends Node2D

onready var myTime = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	$myText.percent_visible = 0
	var _anim_player = $SceneTranstion/AnimationPlayer
	_anim_player.play_backwards("fade")
	yield(_anim_player, "animation_finished")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$myText.percent_visible += delta/30
	if $myText.percent_visible >= 1:
		myTime+=delta

func _input(event):
	if event is InputEventKey and $myText.percent_visible != 1:
		$myText.percent_visible = 1
	if event is InputEventKey and myTime > 0.5:
		var _anim_player = $SceneTranstion/AnimationPlayer
		_anim_player.play("fade")
		yield(_anim_player, "animation_finished")
		get_tree().change_scene("res://Main.tscn")

