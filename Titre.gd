extends Node2D

var time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	var _anim_player = $SceneTranstion/AnimationPlayer
	_anim_player.play_backwards("fade")
	yield(_anim_player, "animation_finished")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	$SubTitleLabel2.modulate.a = abs(sin(time))

func _input(event):
	if event is InputEventMouseButton:
		var index = event.button_index
		var wheel
		match index:
			BUTTON_WHEEL_DOWN:
				wheel = true
			BUTTON_WHEEL_UP:
				wheel = true
			BUTTON_WHEEL_LEFT:
				wheel = true
			BUTTON_WHEEL_RIGHT:
				wheel = true
			_:
				wheel = false
		if event.pressed and !wheel:
			var _anim_player = $SceneTranstion/AnimationPlayer
			_anim_player.play("fade")
			yield(_anim_player, "animation_finished")
			get_tree().change_scene("res://Pre-main.tscn")
	else:
		if event is InputEventKey:
			var _anim_player = $SceneTranstion/AnimationPlayer
			_anim_player.play("fade")
			yield(_anim_player, "animation_finished")
			get_tree().change_scene("res://Pre-main.tscn")
		
