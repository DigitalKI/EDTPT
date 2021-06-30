extends Control

var ship_button_res = preload("res://TabScreens/ShipButton.tscn")

# Called when the node enters the scene tree for the first time.
func initialize_ships_tab():
	for shipb in $MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer.get_children():
		shipb.queue_free()

	for ship in data_reader.ships_manager.current_stored_ships:
		var ship_dct : Dictionary = data_reader.ships_manager.current_stored_ships[ship]
		print(data_reader.ships_manager.current_stored_ships[ship])
		var ship_btn = ship_button_res.instance()
		ship_btn.ship_id = ship_dct["ShipID"]
		ship_btn.ShipType = ship_dct["ShipType_Localised"] if ship_dct.has("ShipType_Localised") else ship_dct["ShipType"]
		ship_btn.ShipName =  ship_dct["Name"] if ship_dct.has("Name") else ship_btn.ShipType
		$MarginContainer/HBoxContainer/ScrollContainer/VBoxContainer.add_child(ship_btn)
