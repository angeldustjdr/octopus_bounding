extends Node2D

# Declare member variables here. Examples:
var base_volume

# Called when the node enters the scene tree for the first time.
func _ready():
	base_volume = $BGmusic.volume_db

func set_volume_for_pause(pause,mode):
	if (pause and mode == 0):
		$BGmusic.volume_db = base_volume - 15
	else:
		$BGmusic.volume_db = base_volume
