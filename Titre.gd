extends Node2D

var time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	$SubTitleLabel2.modulate.a = abs(sin(time))

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			var _anim_player = $SceneTranstion/AnimationPlayer
			_anim_player.play("fade")
			yield(_anim_player, "animation_finished")
			get_tree().change_scene("res://Pre-main.tscn")
