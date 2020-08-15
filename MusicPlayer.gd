extends Node2D

onready var random = randomize()

func _process(delta):
	if $AudioStreamPlayer.playing == false :
		var myMusic = randi()%8 + 1
		$AudioStreamPlayer.stream = load("res://Assets/music/"+str(myMusic)+".ogg")
		$AudioStreamPlayer.play()
