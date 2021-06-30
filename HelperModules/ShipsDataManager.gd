extends Object
class_name ShipsDataManager

var stored_ships_events
var current_stored_ships : Dictionary = {}
var ships_loadout_events
var ships_loadout : Dictionary = {}



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
								current_stored_ships[int(ship["ShipID"])] = ship
				elif ship_evt.has("ShipsRemote") && ship_evt["ShipsRemote"].size() > 0:
							for ship in ship_evt["ShipsRemote"]:
								current_stored_ships[int(ship["ShipID"])] = ship
	return current_stored_ships.size()

func get_ships_loadoud():
	ships_loadout_events = data_reader.get_all_events_by_type("Loadout")
	if ships_loadout_events:
		for ship_loadout in ships_loadout_events:
			var evt_datetime = DateTime.new(ship_loadout["timestamp"]).unix_time
			if ships_loadout.has(int(ship_loadout["ShipID"])):
				var existing_datetime = DateTime.new(ships_loadout[int(ship_loadout["ShipID"])]["timestamp"]).unix_time
				if evt_datetime > existing_datetime:
					ships_loadout[int(ship_loadout["ShipID"])] = ship_loadout
			else:
				ships_loadout[int(ship_loadout["ShipID"])] = ship_loadout
	return ships_loadout.size()
	
func get_max_hull_value(_relative : bool = true):
	var max_hull = 0
	if _relative:
		for idx in ships_loadout:
			if ships_loadout[idx].has("HullValue"):
				if max_hull < ships_loadout[idx]["HullValue"]:
					max_hull = ships_loadout[idx]["HullValue"]
	return max_hull
	
func get_max_jump_range(_relative : bool = true):
	var max_jump = 0
	if _relative:
		for idx in ships_loadout:
			if ships_loadout[idx].has("MaxJumpRange"):
				if max_jump < ships_loadout[idx]["MaxJumpRange"]:
					max_jump = ships_loadout[idx]["MaxJumpRange"]
	return max_jump
