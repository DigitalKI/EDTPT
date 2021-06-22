extends Control

var stored_ships = {}
var stored_ships_events


# Called when the node enters the scene tree for the first time.
func initialize_ships_tab():
	stored_ships_events = data_reader.get_event_by_type("StoredShips")
	if stored_ships_events:
		for ship_evt in stored_ships_events:
			if ship_evt.has("ShipsHere") && ship_evt["ShipsHere"].size() > 0:
						for ship in ship_evt["ShipsHere"]:
							stored_ships[ship["ShipID"]] = ship
			elif ship_evt.has("ShipsRemote") && ship_evt["ShipsRemote"].size() > 0:
						for ship in ship_evt["ShipsRemote"]:
							stored_ships[ship["ShipID"]] = ship
	print(stored_ships)
