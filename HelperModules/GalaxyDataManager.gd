extends Node
class_name GalaxyDataManager

var fsd_jumps_events #all the jump events
var star_systems : Array = [] #the unique star addresses


# Stores all the jump events, star systems addreses, and group jumps per system address
func get_systems_by_visits():
	if data_reader.dbm.db.query("SELECT *, COUNT(*) Visits"
											+ " FROM FSDJump"
											+ " WHERE CMDRId = " + String(data_reader.current_cmdr["Id"])
											+ " GROUP BY SystemAddress HAVING MAX(timestamp)"
											+ " ORDER BY COUNT(*) DESC"):
		star_systems = data_reader.dbm.db.query_result.duplicate()
	return star_systems

# Stores all the jump events, star systems addreses, and group jumps per system address
func get_systems_by_rings():
	var query = "SELECT F.*, COUNT(DISTINCT S.BodyID) RingsAmount, IIF(COUNT(DISTINCT S.BodyID) > 0, 1, 0) Ringed" \
							+ " FROM FSDJump F" \
							+ " LEFT JOIN Scan S" \
							+ " ON (F.SystemAddress = S.SystemAddress AND length(S.Rings) > 0)" \
							+ " WHERE F.CMDRId = " + String(data_reader.current_cmdr["Id"]) \
							+ " GROUP BY F.SystemAddress" \
							+ " HAVING MAX(F.timestamp)" \
							+ " ORDER BY COUNT(DISTINCT S.BodyID) DESC"
	if data_reader.dbm.db.query(query):
		star_systems = data_reader.dbm.db.query_result.duplicate()
		for star in star_systems:
			star["prospected"] = false
			var prospecting_events = get_events_per_location(String(star["SystemAddress"]), -1, ["ProspectedAsteroid"])
			if prospecting_events.size() > 0:
				star["prospected"] = true
				print("%s is %s" % [star["StarSystem"], star["prospected"]])
	else:
		star_systems = []
	return star_systems

# Gets the initial and final timestamps per location, and store them in an array,
# each item is a pair of timestamps where you're supposedly in the same place.
func _get_location_time_periods(_sysaddress : String, _bodyId : int = -1) -> Array:
	var result = []
	# StartJump is used instead of SupercruiseEntry, it is equivalent.
	var query = "SELECT A.Id, A.SystemAddress, A.BodyID, A.Body, A.timestamp as entered, B.Id, B.timestamp as exited" \
				+ " FROM SupercruiseExit as A" \
				+ " INNER JOIN StartJump as B" \
				+ " ON b.timestamp > A.timestamp" \
				+ " WHERE A.SystemAddress = " + _sysaddress
	if _bodyId >= 0:
		query += " AND A.BodyID = " + String(_bodyId)
	query += " GROUP BY A.Id, A.BodyID" \
			+ " HAVING MIN(B.timestamp) = b.timestamp" # This ensures th timestamp when leaving normal space is the closest
	if data_reader.dbm.db.query(query):
		result = data_reader.dbm.db.query_result.duplicate()
	return result

func get_events_per_location( _sysaddress : String, _bodyId : int = -1, _types : Array = []):
	var timeranges := _get_location_time_periods(_sysaddress, _bodyId)
	for t_rng in timeranges:
		t_rng["local_events"] = data_reader.get_all_db_events_by_type(_types, 0, 0, t_rng["entered"], t_rng["exited"])
	for idx in range(timeranges.size()-1, -1, -1):
		if timeranges[idx]["local_events"].empty():
			timeranges.remove(idx)
	return timeranges
