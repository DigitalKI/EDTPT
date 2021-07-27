extends Node
class_name GalaxyDataManager

var fsd_jumps_events
var star_systems : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_all_jumped_systems():
	fsd_jumps_events = data_reader.get_all_events_by_type(["FSDJump"])
	for jump in fsd_jumps_events:
		if star_systems.find(jump["SystemAddress"]) == -1:
			star_systems.append(jump["SystemAddress"])
	return fsd_jumps_events
