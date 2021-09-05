extends Node
class_name edsmDataManager

var get_systems_cube := "https://www.edsm.net/api-v1/cube-systems"
var http_request : HTTPRequest
var max_range := 200.0

var star_systems := []
# The list of sectors to download
var sectors_list : Array = []
# Source of the urls: https://www.edsm.net/en/nightly-dumps
const files_download_urls : Dictionary = {"All Inhabited": "https://www.edsm.net/dump/systemsPopulated.json.gz"
										, "All With coordinates": "https://www.edsm.net/dump/systemsWithCoordinates.json.gz"
										, "Systems, last 7 days": "https://www.edsm.net/dump/systemsWithCoordinates7days.json.gz"
										, "Bodies, last 7  days": "https://www.edsm.net/dump/bodies7days.json.gz"
										, "Powerplay": "https://www.edsm.net/dump/powerPlay.json.gz"
										, "Stations": "https://www.edsm.net/dump/stations.json.gz"
										, "Codex": "https://www.edsm.net/dump/codex.json.gz"}

signal systems_received

# Called when the node enters the scene tree for the first time.
func add_http_reader():
	if !http_request:
		http_request = HTTPRequest.new()
		http_request.use_threads = true
		http_request.connect("request_completed", self, "_http_request_completed")

func _read_systems_from_file(_filename : String, _batch_size : int = 0, _seek_pos : int = 0):
	var file = File.new()
	var file_size : int = 0
	var jjournal : JSONParseResult
	var f_events = []
	var file_status = file.open("user://Database/" + _filename, File.READ)
	if file_status == OK:
		file_size = file.get_len() #for some reason returns 0, maybe related to Godot's #47254
		file.seek(_seek_pos)
		var content : String = ""
		while !file.eof_reached():
			content = file.get_line()
			if content is String:
				if content.dedent().begins_with("{"):
					content = content.dedent().trim_suffix(",")
					jjournal = JSON.parse(content)
					if jjournal.result is Dictionary:
						f_events.append(jjournal.result)
						if f_events.size() >= _batch_size && _batch_size > 0:
							var pos : int = file.get_position()
							print("We are here: %s" % float(pos))
							file.close()
							return {"events": f_events, "position": pos}
					else:
						logger.log_event("Problem with this file: %s" % _filename)
						logger.log_event("  Here: %s" % content)
		file.close()
	else:
		logger.log_event("Cannot read log file %s, status: %s" % [_filename, file_status])
	return {"events": f_events, "position": -1}

func _7z_extract(_file_to_extract : String):
	var settings = data_reader.settings_manager.get_settings()
	var sevenz_exec_path : String = settings["Tb7ZPath"] if settings.has("Tb7ZPath") else "C:/Program Files/7-Zip/7z.exe"
	var sevenz_exec_standalone := OS.get_user_data_dir() + "/Database/7z1900-extra/x64/7za.exe"
	var extract_from := ("\"%s/Database/%s\"" % [OS.get_user_data_dir(), _file_to_extract]).replace("/", "\\")
	var extract_to := ("-o\"%s/Database\"" % [OS.get_user_data_dir()]).replace("/", "\\")
	var parameters := [extract_from, extract_to]
	var output : Array = []
	var error = OS.execute(sevenz_exec_path, ["x", extract_from, extract_to], true, output)
	if error:
		logger.log_event(String(error))
	if output:
		logger.log_event(String(output))
	return error

func get_systems_from_file(_filename : String = ""):
	var current_position = 0
	while current_position != -1:
		var s_systems_result = _read_systems_from_file(_filename, 100000, current_position)
		current_position = s_systems_result["position"]
		_write_systems_to_db(s_systems_result["events"], false)

func get_systems_in_cube(_coords : Vector3, _size_ly : float):
	if http_request.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		_size_ly = max_range if _size_ly > max_range else _size_ly
		var params := "?x=%s&y=%s&z=%s&size=%s&showId=1&showCoordinates=1&showPermit=1&showInformation=1&showPrimaryStar=1" % [_coords.x, _coords.y, _coords.z, _size_ly]
		var error = http_request.request(get_systems_cube + params)
		if error != OK:
			logger.log_event("An error occurred in the HTTP request.")

func download_edsm_file(_filename : String, _file_url : String):
	if http_request.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		http_request.download_file = "user://Database/" + _filename
		var error = http_request.request(_file_url)
		if error != OK:
			logger.log_event("An error occurred in the HTTP request.")

func get_systems_cube_array(_sector : Vector3, _radius : int = 1):
	var _sectors_list : Array = []
	for idxx in range(- _radius, _radius + 1):
		for idxy in range(- _radius, _radius + 1):
			for idxz in range(- _radius, _radius + 1):
				_sectors_list.append(Vector3(idxx, idxy, idxz))
	return _sectors_list

func get_systems_in_cubes_radius(_sector : Vector3, _radius : int = 1):
	sectors_list = get_systems_cube_array(_sector, _radius)
	get_systems_by_sector(sectors_list.pop_back())

func get_systems_in_db(_fields : Array = ["*"], _sectors : Array = [], _emit : bool = false):
	if _sectors.empty():
		star_systems = data_reader.dbm.db.select_rows("edsm_systems", "", _fields)
	else:
		var _sector_x_smallest : int = _sectors[0].x
		var _sector_x_highest : int = _sectors[0].x
		var _sector_y_smallest : int = _sectors[0].y
		var _sector_y_highest : int = _sectors[0].y
		var _sector_z_smallest : int = _sectors[0].z
		var _sector_z_highest : int = _sectors[0].z
		for _sec in _sectors:
			if _sec.x < _sector_x_smallest:
				_sector_x_smallest = _sec.x
			elif _sec.x > _sector_x_highest:
				_sector_x_highest = _sec.x
			if _sec.y < _sector_y_smallest:
				_sector_y_smallest = _sec.y
			elif _sec.y > _sector_y_highest:
				_sector_y_highest = _sec.y
			if _sec.z < _sector_z_smallest:
				_sector_z_smallest = _sec.z
			elif _sec.z > _sector_z_highest:
				_sector_z_highest = _sec.z
		var sql_filter = "sector_x BETWEEN " + String(_sector_x_smallest) + " AND " + String(_sector_x_highest)
		sql_filter += " AND sector_y BETWEEN "  + String(_sector_y_smallest) + " AND " + String(_sector_y_highest)
		sql_filter += " AND sector_z BETWEEN "  + String(_sector_z_smallest) + " AND " + String(_sector_z_highest)
		print(sql_filter)
		star_systems = data_reader.dbm.db.select_rows("edsm_systems", sql_filter, _fields)
	if _emit:
		emit_signal("systems_received")
	return star_systems

func extract_systems_id():
	var systems_ids : Array = []
	for ss in star_systems:
		systems_ids.append(ss["Id"])
	return systems_ids

func get_systems_by_sector(_sector : Vector3):
	var sector_center : Vector3 = _sector.floor() * max_range
	# Reducing the range by the smallest amount in order to avoid repeated systems.
	# It happens, really.
	get_systems_in_cube(sector_center, max_range - 0.000001)

func _prepare_insert_events(_edsm_retrieved_systems : Array, _check_id : bool = true) -> Array:
	var insert_events : Array = []
	var edsm_ids : Array = []
	if !_edsm_retrieved_systems.empty():
		if _check_id:
			get_systems_in_db(["id"])
			edsm_ids = extract_systems_id()
		for evt in _edsm_retrieved_systems:
				if !edsm_ids.has(int(evt["id"])) && evt["id64"]:
					evt["sector_x"] = floor(evt["coords"]["x"] / max_range)
					evt["sector_y"] = floor(evt["coords"]["y"] / max_range)
					evt["sector_z"] = floor(evt["coords"]["z"] / max_range)
					insert_events.append(data_reader.dbm.convert_data_to_inserts(evt, false))
					edsm_ids.append(evt["id"])
	return insert_events

func _write_systems_to_db(_edsm_systems : Array, _check_ids : bool = true):
	var insert_events = _prepare_insert_events(_edsm_systems, _check_ids)
	if !data_reader.dbm.db.insert_rows("edsm_systems", insert_events): 
		logger.log_event(data_reader.dbm.db.error_message)
		logger.log_event("There was a problem adding EDSM Systems data.")

func _http_request_completed(result, response_code, headers, body):
	var string_result : String = body.get_string_from_utf8()
	var edsm_retrieved_systems : Array = []
	if http_request.download_file.empty():
		if string_result.length() > 2:
			edsm_retrieved_systems = parse_json(string_result)
			_write_systems_to_db(edsm_retrieved_systems)
		if sectors_list.size() > 0:
			get_systems_by_sector(sectors_list.pop_back())
		else:
			emit_signal("systems_received")
	else:
		if !_7z_extract(http_request.download_file.get_file()):
			var filename_extracted := http_request.download_file.get_file()
			filename_extracted = filename_extracted.replace("." + filename_extracted.get_extension(), "")
			get_systems_from_file(filename_extracted)
	http_request.download_file = ""
