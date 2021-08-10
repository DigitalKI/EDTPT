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
		star_systems = data_reader.db.query_result.duplicate()
	return star_systems


func _get_location_time_periods(_sysaddress : String, _bodyId : int = -1) -> Array:
	var result = []
	# Gets the initial and final timestamps per location
	var query = "SELECT A.Id, A.SystemAddress, A.BodyID, A.Body, A.timestamp as entered, B.Id, B.timestamp as exited" \
				+ " FROM SupercruiseExit as A" \
				+ " INNER JOIN StartJump as B" \
				+ " ON b.timestamp > A.timestamp" \
				+ " WHERE A.SystemAddress = " + _sysaddress
	if _bodyId >= 0:
		query += " AND A.BodyID = " + String(_bodyId)
	query += " GROUP BY A.Id, A.BodyID" \
			+ " HAVING MIN(B.timestamp) = b.timestamp"
	if data_reader.db.query(query):
		result = data_reader.db.query_result.duplicate()
	return result

func get_events_per_location( _sysaddress : String, _bodyId : int = -1, _types : Array = []):
	var timeranges := _get_location_time_periods(_sysaddress, _bodyId)
	for t_rng in timeranges:
		t_rng["local_events"] = data_reader.get_all_db_events_by_type(_types, 9999, 0, t_rng["entered"], t_rng["exited"])
	for idx in range(timeranges.size()-1, -1, -1):
		if timeranges[idx]["local_events"].empty():
			timeranges.remove(idx)
	return timeranges
