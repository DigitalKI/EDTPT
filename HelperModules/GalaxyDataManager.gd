extends Node
class_name GalaxyDataManager

var fsd_jumps_events #all the jump events
var star_systems : Array = [] #the unique star addresses
var star_systems_data : Array = [] #jumps per address, same size as star_systems, to easily get events per system

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Stores all the jump events, star systems addreses, and grpou jumps per system address
func get_all_jumped_systems():
	fsd_jumps_events = data_reader.get_all_events_by_type(["FSDJump"])
	for jump in fsd_jumps_events:
		if star_systems.find(jump["SystemAddress"]) == -1:
			star_systems.append(jump["SystemAddress"])
			star_systems_data.append([jump])
		else:
			star_systems_data[star_systems.find(jump["SystemAddress"])].append(jump)
	return fsd_jumps_events
