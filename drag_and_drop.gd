extends KinematicBody2D

export var NPC_name = "?"
export var NPC_type = "?"

export var initial_position = Vector2(0, 0)
var dragging = false
var clicked = false
var pickable = true
var available = true

signal dragged(npc_id)

func _ready():
	initial_position = position
	$NPC_info.text = NPC_name+" ("+NPC_type+")"
	match NPC_type:
		"You":
			$Outline.color=Color(0,0,0,1)
		"Brawl":
			$Outline.color=Color(1,0,0,0.5)
		"Wit":
			$Outline.color=Color(0,0,1,0.5)
	$AnimationPlayer.play("NPCenter")
	yield($AnimationPlayer, "animation_finished")

func _process(_delta):
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.position = Vector2(mousepos.x, mousepos.y)
	else:
		go_back_to_initial_position()

func _on_Character_input_event(_viewport, event, _shape_idx):
	if pickable :
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed and !dragging:
				dragging = true
				emit_signal("dragged",self)

func go_back_to_initial_position():
	dragging = false
	position = initial_position

func _on_Character_mouse_entered():
	$NPC_info.visible=true

func _on_Character_mouse_exited():
	$NPC_info.visible=false

func _on_AnimationPlayer_animation_finished(anim_name):
	$Outline.visible = true

func make_not_available():
	$pickableFilter.visible = true
	$notAvailableTexture.visible = true
	available = false
	pickable = false
	
func make_available():
	$pickableFilter.visible = false
	$notAvailableTexture.visible = false
	available = true
	pickable = true
