extends Object
class_name ShipsDataManager

var stored_ships_events
var current_stored_ships : Dictionary = {}
var ships_loadout


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_stored_ships():
	stored_ships_events = data_reader.get_all_events_by_type("StoredShips")
	var latest_stored_ship_evt : int = 0
	if stored_ships_events:
		for ship_evt in stored_ships_events:
			var evt_datetime = DateTime.new(ship_evt["timestamp"]).unix_time
			if evt_datetime > latest_stored_ship_evt:
				latest_stored_ship_evt = evt_datetime
				if ship_evt.has("ShipsHere") && ship_evt["ShipsHere"].size() > 0:
							for ship in ship_evt["ShipsHere"]:
								current_stored_ships[ship["ShipID"]] = ship
				elif ship_evt.has("ShipsRemote") && ship_evt["ShipsRemote"].size() > 0:
							for ship in ship_evt["ShipsRemote"]:
								current_stored_ships[ship["ShipID"]] = ship
	return current_stored_ships.size()
