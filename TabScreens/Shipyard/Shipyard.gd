extends Control

var ship_button_res = preload("res://TabScreens/Shipyard/ShipButton.tscn")

# Called when the node enters the scene tree for the first time.
func initialize_ships_tab():
	# free existing ship buttons
	for shipb in $MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer.get_children():
		shipb.queue_free()
	# read ships data and append a new ShipButton
	for ship_idx in data_reader.ships_manager.current_stored_ships:
		var ship_dct : Dictionary = data_reader.ships_manager.current_stored_ships[ship_idx]
		var ship_loadout : Dictionary = {}
		if data_reader.ships_manager.ships_loadout.has(ship_idx):
			ship_loadout = data_reader.ships_manager.ships_loadout[ship_idx]
			print(data_reader.ships_manager.ships_loadout[ship_idx])
#		print(data_reader.ships_manager.current_stored_ships[ship_idx])
		var ship_btn : ShipButton = ship_button_res.instance()
		ship_btn.ship_id = ship_dct["ShipID"]
		ship_btn.ShipType = ship_dct["ShipType_Localised"] if ship_dct.has("ShipType_Localised") else ship_dct["ShipType"]
		ship_btn.ShipName =  ship_dct["Name"] if ship_dct.has("Name") else ship_btn.ShipType
		if ship_loadout:
			ship_btn.MaxHull = data_reader.ships_manager.get_max_hull_value()
			ship_btn.Hull = ship_loadout["HullValue"]
			ship_btn.MaxJump = data_reader.ships_manager.get_max_jump_range()
			ship_btn.Jump = ship_loadout["MaxJumpRange"]
		else:
			ship_btn.MaxJump = data_reader.ships_manager.get_max_jump_range()
			ship_btn.Hull = 0
			ship_btn.Jump = 0
		$MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer.add_child(ship_btn)
