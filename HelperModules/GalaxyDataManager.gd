extends Node
class_name GalaxyDataManager

var fsd_jumps_events

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_all_jumped_systems():
	fsd_jumps_events = data_reader.get_all_events_by_type(["FSDJump"])
	return fsd_jumps_events
