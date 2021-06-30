extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().set_transparent_background(true)
#	OS.set_window_mouse_passthrough($Panel/VBoxContainer/PassThroughPoly.polygon)

	pass # Replace with function body.


func _on_BtLogs_pressed():
	$TabContainer.current_tab = 0


func _on_BtShips_pressed():
	$TabContainer.current_tab = 1
	$TabContainer/TabShips/Ships.initialize_ships_tab()
