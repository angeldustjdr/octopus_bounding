extends Node2D

onready var myTime = 0
onready var time = 0
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
	time += delta
	$Label.modulate.a = 0.5+0.5*sin(2*time)

func _input(event):
	if (event is InputEventKey or event is InputEventMouseButton) and $myText.percent_visible != 1:
		$myText.percent_visible = 1
	if (event is InputEventKey or event is InputEventMouseButton) and myTime > 0.2:
		var _anim_player = $SceneTranstion/AnimationPlayer
		_anim_player.play("fade")
		yield(_anim_player, "animation_finished")
		get_tree().change_scene("res://Main.tscn")

