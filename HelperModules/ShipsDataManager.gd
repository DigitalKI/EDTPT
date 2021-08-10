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
	stored_ships_events = data_reader.get_all_db_events_by_type(["StoredShips"])
	var latest_stored_ship_evt : int = 0
	if stored_ships_events:
		for ship_evt in stored_ships_events:
			var evt_datetime = DateTime.new(ship_evt["timestamp"]).unix_time
			if evt_datetime > latest_stored_ship_evt:
				latest_stored_ship_evt = evt_datetime
				if ship_evt.has("ShipsHere"):
					var ships_here := JSON.parse(ship_evt["ShipsHere"])
					if ships_here.result is Array:
						for ship in ships_here.result:
							current_stored_ships[int(ship["ShipID"])] = ship
				elif ship_evt.has("ShipsRemote"):
					var ships_remote := JSON.parse(ship_evt["ShipsRemote"])
					if ships_remote.result is Array:
						for ship in ships_remote.result:
							current_stored_ships[int(ship["ShipID"])] = ship
	return current_stored_ships.size()

func get_ships_loadoud():
	ships_loadout.clear()
	ships_loadout_events = data_reader.get_all_db_events_by_type(["Loadout"], 10000)
	if ships_loadout_events:
		for ship_loadout in ships_loadout_events:
			var evt_datetime = DateTime.new(ship_loadout["timestamp"]).unix_time
			if ships_loadout.has(int(ship_loadout["ShipID"])):
				var existing_datetime = DateTime.new(ships_loadout[int(ship_loadout["ShipID"])]["timestamp"]).unix_time
				if ship_loadout["timestamp"] > ships_loadout[int(ship_loadout["ShipID"])]["timestamp"]:
					ships_loadout[int(ship_loadout["ShipID"])] = ship_loadout
			else:
				ships_loadout[int(ship_loadout["ShipID"])] = ship_loadout
	return ships_loadout.size()
	
func get_max_hull_value(_relative : bool = true):
	var max_hull = 0
	if _relative:
		for idx in ships_loadout:
			if ships_loadout[idx].has("HullValue") && ships_loadout[idx]:
				if ships_loadout[idx]["HullValue"] == null:
					ships_loadout[idx]["HullValue"] = 0
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

func get_max_shield_strength(_relative : bool = true):
	var orig_shield = 0
	var max_shield = 0
	if _relative:
		for idx in ships_loadout:
			if ships_loadout[idx].has("Modules"):
				var modules := JSON.parse(ships_loadout[idx]["Modules"])
				if modules.result is Array:
					for module in modules.result:
						if module["Item"].begins_with("int_shieldgenerator"):
							if module.has("Engineering"):
								if module["Engineering"].has("Modifiers"):
									for modifier in module["Engineering"]["Modifiers"]:
										if modifier["Label"] == "ShieldGenStrength" && modifier["Value"] > max_shield:
											orig_shield = modifier["OriginalValue"]
											max_shield = modifier["Value"]
	return max_shield

func get_engineering_value(_ship_loadout, _label):
	var value : float = 0
	if _ship_loadout.has("Modules"):
		var modules := JSON.parse(_ship_loadout["Modules"])
		if modules.result is Array:
			for module in modules.result:
				if module.has("Engineering"):
					if module["Engineering"].has("Modifiers"):
						for modifier in module["Engineering"]["Modifiers"]:
							if modifier["Label"] == _label:
								value = modifier["Value"]
	return value

	
func get_ship_modules(_relative : bool = true):
	var ship_modules : Array = []
	if _relative:
		for idx in ships_loadout:
			if ships_loadout[idx].has("Modules"):
				for module in ships_loadout[idx]["Modules"]:
					ship_modules.append(module)
	return ship_modules
