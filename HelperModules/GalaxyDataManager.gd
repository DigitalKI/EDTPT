extends Node
class_name GalaxyDataManager

var fsd_jumps_events #all the jump events
var star_systems : Array = [] #the unique star addresses

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Stores all the jump events, star systems addreses, and grpou jumps per system address
func get_all_visited_systems():
#	fsd_jumps_events = data_reader.get_all_db_events_by_type(["FSDJump"])
	if data_reader.db.query("SELECT *, COUNT(*) Visits"
											+ " FROM FSDJump"
											+ " WHERE CMDRId = " + String(data_reader.current_cmdr["Id"])
											+ " GROUP BY SystemAddress HAVING MAX(timestamp)"
											+ " ORDER BY COUNT(*) DESC"):
		star_systems = data_reader.db.query_result
	return star_systems
