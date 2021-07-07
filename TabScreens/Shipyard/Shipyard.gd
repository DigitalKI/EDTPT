extends Control

var ship_button_res = preload("res://TabScreens/Shipyard/ShipButton.tscn")

# Called when the node enters the scene tree for the first time.
func initialize_ships_tab():
	var current_max_hull = data_reader.ships_manager.get_max_hull_value()
	var current_max_jump = data_reader.ships_manager.get_max_jump_range()
	# free existing ship buttons
	for shipb in $MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer.get_children():
		shipb.queue_free()
	# read ships data and append a new ShipButton
	for ship_idx in data_reader.ships_manager.ships_loadout:
		var st_ship : Dictionary = {}
		var ship_loadout : Dictionary = data_reader.ships_manager.ships_loadout[ship_idx]
		var ship_btn : ShipButton = ship_button_res.instance()
		if data_reader.ships_manager.current_stored_ships.has(ship_idx):
			st_ship = data_reader.ships_manager.current_stored_ships[ship_idx]
#			print(data_reader.ships_manager.ships_loadout[ship_idx]["Modules"])
#		print(data_reader.ships_manager.current_stored_ships[ship_idx])
		ship_btn.ship_id = ship_loadout["ShipID"]
		ship_btn.ShipType = st_ship["ShipType_Localised"] if st_ship.has("ShipType_Localised") else ship_loadout["Ship"]
		ship_btn.ShipName =  ship_loadout["ShipName"]
		ship_btn.MaxShields = 100
		ship_btn.Shields = 0
		ship_btn.MaxHull = current_max_hull
		ship_btn.Hull = 0
		ship_btn.MaxJump = current_max_jump
		ship_btn.Jump = 0
		if ship_loadout:
			ship_btn.Hull = ship_loadout["HullValue"] if ship_loadout.has("HullValue") else 0
			ship_btn.Jump = ship_loadout["MaxJumpRange"] if ship_loadout.has("MaxJumpRange") else 0
		$MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer.add_child(ship_btn)
