extends Node2D

func _process(delta):
	$InfoBulle.rect_position = get_viewport().get_mouse_position() + Vector2(-120,20)

func _on_InfoBulleMoney_mouse_entered():
	$InfoBulle.text = "This is your money.\nDon't go to deep into debts:\n-100 is game over."
	$InfoBulle.visible=true

func _on_InfoBulleMoney_mouse_exited():
	$InfoBulle.visible=false


func _on_InfoBulleReputation_mouse_entered():
	$InfoBulle.text = "This is your reputation.\nMore reputation unlocks more possibilities.\n0 is game over."
	$InfoBulle.visible=true


func _on_InfoBulleReputation_mouse_exited():
	$InfoBulle.visible=false


func _on_InfoBulleCompromised_mouse_entered():
	$InfoBulle.text = "This is how much you've been compromised.\n100% is game over."
	$InfoBulle.visible=true


func _on_InfoBulleCompromised_mouse_exited():
	$InfoBulle.visible=false


func _on_InfoBulleDay_mouse_entered():
	$InfoBulle.text = "Press escape or \nspace to pause \nthe game."
	$InfoBulle.visible=true

func _on_InfoBulleDay_mouse_exited():
	$InfoBulle.visible=false
	
func manage_pause(stat, _mode):
	if($InfoBulle.visible):
		$InfoBulle.visible = stat
