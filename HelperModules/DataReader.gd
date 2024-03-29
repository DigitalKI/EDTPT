# This script is in charge of reading events from the log journals
# and write them to the database.
# It needs to be cleaned up a bit, it's already a bit messy.

extends Node
class_name DataReader

var thread_reader : Thread = null
var mutex : Mutex
var selected_cmdr setget _set_cmdr
var current_cmdr : Dictionary = {}
var cmdrs : Dictionary = {}
var evt_types : Array
var events : Array = []
var cached_events : Array = []

var timer : Timer
var autoupdate := false setget _set_autoupdate
var settings_manager : SettingsManager = SettingsManager.new()
var file_reader : FileReader = FileReader.new()
var dbm : DatabaseManager = DatabaseManager.new()
onready var edsm_manager : edsmDataManager = edsmDataManager.new()
onready var ships_manager : ShipsDataManager = ShipsDataManager.new()
onready var galaxy_manager : GalaxyDataManager = GalaxyDataManager.new()
onready var matinv_manager : MaterialsAndInventoryManager = MaterialsAndInventoryManager.new()
onready var query_builder : QueryBuilderHelper = QueryBuilderHelper.new()

signal new_cached_events(new_events)


func _ready():
	thread_reader = Thread.new()
	mutex = Mutex.new()
	logger.log_event(file_reader.logs_path)
	
	# Some nodes that are inside data managers need to be added to a node tree
	# We do it programmatically so that we don't need a scene for them
	var current_scene = get_tree().current_scene
	
	# First one is the HttpRequest node
	edsm_manager.add_http_reader()
	current_scene.add_child(edsm_manager.http_request)
	
	# Let's check if the journals are found or else set the custom path
	if !file_reader.check_logs_path(current_scene):
		file_reader.set_custom_journal_path(current_scene)
	
	# The second is the timer
	initialize_timer(current_scene)
	
	_set_cmdr("")
	
	# Arrays usually are by ref, so we should be covered for updates 
	evt_types = dbm.event_types
	if autoupdate:
		timer.start()

func _exit_tree():
	timer.stop()
	if thread_reader.is_active():
		thread_reader.wait_to_finish()

func _set_autoupdate(_value):
	autoupdate = _value
	if autoupdate:
		timer.start()
	else:
		timer.stop()

func _set_cmdr(_value : String):
	var cmdr_res = dbm.db.select_rows("Commander", ("name = " + _value) if _value else "", ["*"])
	if !cmdr_res.empty():
		current_cmdr = cmdr_res[0]

func initialize_timer(_current_scene_root):
	timer = Timer.new()
	_current_scene_root.add_child(timer)
	timer.wait_time = 2
	timer.one_shot = true
	timer.connect("timeout", self, "timer_read_cache")
	# maybe I shouldn't start it immediately as I have to prepare the database
	# and read eventual new files
#	timer.start()

func timer_read_cache():
	if settings_manager.get_setting("Threaded"):
		journal_updates_threaded()
	else:
		journal_updates()

func journal_updates_threaded():
	if thread_reader.is_active():
		thread_reader.wait_to_finish()
	thread_reader.start(self, "journal_updates", true)

func journal_updates(_threaded = false):
	var returnval = null
	if _threaded:
		mutex.lock()
	var new_logs = _get_new_log_objects()
	if _threaded:
		mutex.unlock()
		call_deferred("reset_thread")
		returnval = new_logs
	else:
		emit_signal("new_cached_events", new_logs["events"])
		_set_autoupdate(autoupdate)
		# As it manipulates the events dictionary, it's left last,
		# so that the journal reader will still be intact
		# It will run only when not threaded
		# , in which case it will be done at reset_thread.
		_write_all_events_to_db(new_logs["byfile"])
	if !current_cmdr:
		_set_cmdr("")
	return returnval

func reset_thread():
	var new_events = {"events":[]}
	if !thread_reader.is_alive():
		new_events = thread_reader.wait_to_finish()
	emit_signal("new_cached_events", [] if new_events == null else new_events["events"])
	if new_events:
		_write_all_events_to_db(new_events["byfile"])
	_set_autoupdate(autoupdate)

func db_get_log_files(_filename : String = ""):
	var filter = "" if _filename.empty() else "filename = '" + _filename + "'"
	var selected_array = dbm.db.select_rows("Fileheader", filter, ["*"])
	return selected_array

func db_get_last_logfile():
	dbm.db.query("SELECT * FROM Fileheader ORDER BY filename desc LIMIT 1;")
	return dbm.db.query_result.duplicate()

func db_get_all_cmdrs():
	var selected_array = dbm.db.select_rows("Commander", "", ["*"])
	for cmdr in selected_array:
		cmdrs[cmdr["FID"]] = cmdr["Name"]
	return cmdrs

func _get_new_log_objects(_nullparam = null):
	var events : Array = []
	var new_log_events : Dictionary = {}
	var all_log_files = file_reader.get_files()
	var log_files_to_parse = []
	var total_files = 0
	var total_events = 0
	for log_file in all_log_files:
		var parsed_logfiles = db_get_log_files(log_file)
		var file_size = file_reader.get_file_size(log_file)
		if parsed_logfiles.empty() || file_size > parsed_logfiles[0]["filesize"]:
			log_files_to_parse.append(log_file)
			total_files += 1
			
	var current_file = 1
	for file_to_parse in log_files_to_parse:
		logger.log_event("reading \"%s\" %s of %s"  % [file_to_parse, current_file, total_files])
		current_file += 1
		var seek_to = 0
		var existing_logfile : Array = db_get_log_files(file_to_parse)
		if !existing_logfile.empty():
			seek_to = existing_logfile[0]["filesize"]
		var curr_logobj = file_reader.get_file_events(file_to_parse, seek_to)
		# here you should update the filesize in the db
		# so that next time it will seek to the right position
		if !existing_logfile.empty():
			dbm.db.update_rows("Fileheader", "filename = '" + file_to_parse + "'", {"filesize": curr_logobj["filesize"]})
		# Inserts new commander if that's the case.
		if dbm.db.select_rows("Commander", "FID = '" + curr_logobj["FID"] + "'", ["*"]).empty():
			if !dbm.db.insert_rows("Commander", [
				{"FID": curr_logobj["FID"], "name": curr_logobj["name"]}
			]):
				logger.log_event("There was a problem adding a new CMDR")
		if curr_logobj["name"]:
			# Selects the current commander,
			# should be changed to saved parameters instead.
			cmdrs[curr_logobj["FID"]] = curr_logobj["name"]
			if !selected_cmdr:
				selected_cmdr = curr_logobj["name"]
		new_log_events[file_to_parse] = curr_logobj.duplicate()
		events.append_array(new_log_events[file_to_parse]["events"])
		total_events += new_log_events[file_to_parse]["events"].size()
	if total_events:
		logger.log_event("total events : %s" % total_events)
	return {"byfile": new_log_events, "events": events}

# The file writes all events to the database,
# we save all events in different tables,
# but each table has a reference to it's belonging fileheader/journal file.
# This means that for each file we have first to save the fileheader,
# then the events.
func _write_all_events_to_db(_new_log_events : Dictionary):
	var all_insert_events := {}
	for log_file in _new_log_events.keys():
		if log_file.begins_with("Journal."):
			var fid = _new_log_events[log_file]["FID"]
			var dobj = _new_log_events[log_file]["events"]
			var filesize = _new_log_events[log_file]["filesize"]
			_get_insert_events_from_object(dobj, fid, log_file, filesize, _new_log_events, all_insert_events)
	# Ready to insert values!
	for table_name in all_insert_events.keys():
		if !all_insert_events[table_name].empty():
			logger.log_event("Adding %s events of type %s" % [all_insert_events[table_name].size(), table_name])
			if !dbm.db.insert_rows(table_name, all_insert_events[table_name]):
				logger.log_event("There was a problem adding events for table %s" % table_name)

# This function first writes to DB the fileheader entries,
# then it generate the write events divided by event type.
# Each event will have it's respective CMDRId and FileheaderId
func _get_insert_events_from_object(_dobj : Array, _fid : String, _log_file_name : String, _log_fise_size : int, _new_log_events : Dictionary, _all_insert_events : Dictionary = {}):
	if _log_file_name.begins_with("Journal."):
		var fileheader : Dictionary = {}
		var fileheader_last_id = 0
		# looks within the new events if there is the fileheader event
		for header_evt in get_events_by_type(["Fileheader"], _dobj, true):
			fileheader = header_evt
			fileheader["filename"] = _log_file_name
		# Let's also check if thre is a fileheader for that journal already
		var existing_fileheader = dbm.db.select_rows("Fileheader", "filename = '" + _log_file_name + "'", ["*"])
		#If the fileheader is not empty it might be a new journal entry
		if !fileheader.empty():
			# That only if the same fileheader is not found in the database
			if existing_fileheader.empty():
				dbm.db.insert_row("Fileheader",
				{"part": fileheader["part"]
				, "language": fileheader["language"]
				, "Odyssey": fileheader["Odyssey"] if fileheader.has("Odyssey") else 0
				, "gameversion": fileheader["gameversion"]
				, "build": fileheader["build"]
				, "filename": fileheader["filename"]
				, "filesize": _log_fise_size
				})
				fileheader_last_id = dbm.db.last_insert_rowid
			else:
				# If instead we find someting se reuse the same Id
				# It may never hapen but we never know with all the changes made
				fileheader_last_id = existing_fileheader[0]["Id"]
		elif !existing_fileheader.empty():
			# In case there is no fileheader but there is an existing one
			# we use that
			fileheader_last_id = existing_fileheader[0]["Id"]
		else:
			# In case there is no existing fileheader and neither a new one
			# it probably means the file is empty, save it anyhow in order
			# to avoid reading it over and over.
			if _log_fise_size == 0:
				if !dbm.db.insert_row("Fileheader",
					{"part": 0
					, "language": ""
					, "Odyssey": 0
					, "gameversion": ""
					, "build": ""
					, "filename": _log_file_name
					, "filesize": _log_fise_size
					}):
					logger.log_event("Error writing empty fileheader entry.")
			logger.log_event("Fileheader not found! Skipping log file.")
			return _all_insert_events
		var cmdr_id_result = dbm.db.select_rows("Commander", "FID = '" + _fid + "'", ["*"])
		if !cmdr_id_result.empty():
			var cmdr_id = cmdr_id_result[0]["Id"]
			for evt in _dobj:
				if evt is Dictionary && evt.has("event"):
					var current_event_type = evt["event"]
					if !_all_insert_events.has(current_event_type):
						_all_insert_events[current_event_type] = []
					# This part of the code may not be needed anymore as there is now a script that pre-generates
					# all the necessary tables
					if !dbm.event_types.has(current_event_type) && current_event_type != "Commander" && current_event_type != "Fileheader":
						var typed_events = get_all_new_events_by_type([current_event_type], _new_log_events)
						create_update_table_from_examples(current_event_type, typed_events)
					if fileheader_last_id <= 0:
						logger.log_event("No fileheader id to use! Aborting")
						continue
					if current_event_type != "Commander" && current_event_type != "Fileheader":
						# Removing event column as each type goes into a separate table
						evt.erase("event")
						#CNDRId and FileheaderId are added and assigned
						evt["CMDRId"] = cmdr_id
						evt["FileheaderId"] = fileheader_last_id
						dbm.convert_data_to_inserts(evt)
						_all_insert_events[current_event_type].append(evt)
	return _all_insert_events

func create_update_table_from_examples(_event_type : String, _typed_events : Array, _update : bool = false):
	var example_event : Dictionary = {}
	example_event["event"] = _event_type
	for evtt in _typed_events:
		for evt_k in evtt.keys():
			if !example_event.has(evt_k):
				example_event[evt_k] = evtt[evt_k] if evtt[evt_k] else "string"
	if _update:
		dbm.update_table_from_data(_event_type, example_event)
	else:
		dbm.create_table_from_event(example_event)

func get_events_by_type(_event_types : Array, _dataobject, _first : bool = false):
	var evt_lst : Array = []
	for evt in _dataobject:
		if evt is Dictionary && evt.has("event") && _event_types.has(evt["event"]):
			evt_lst.append(evt)
			if _first:
				break
	return evt_lst

func get_all_db_events_by_type(_event_types : Array, _amount : int = 1000, _range : int = 0, _timestart = "", _timeend = "") -> Array:
	var evt_lst : Array = []
	var current_amount = (" LIMIT " + String(_range)) if _amount > 0 else ""
	var current_range = "" if _amount == 0 else (", " + String(_amount))
	for evt_typ in _event_types:
		if !dbm.db.select_rows("sqlite_master", "type = 'table' AND name='"+ evt_typ + "'", ["*"]).empty():
			var table_select = "SELECT '" + evt_typ + "' as event, tbl.* FROM " + evt_typ + " AS tbl WHERE 1=1"
			if _timestart:
				table_select += " AND timestamp >= '" +_timestart + "'"
			if _timeend:
				table_select += " AND timestamp <= '" +_timeend + "'"
				
			table_select += " order by timestamp desc"
			table_select +=  current_amount + current_range
			dbm.db.query(table_select)
			evt_lst.append_array(dbm.db.query_result.duplicate())
	evt_lst.sort_custom(ArraySorter.EventsSorter, "sort_ascending")
	return evt_lst

func get_all_db_events_by_file(_event_files : Array):
	var log_objects = {}
	var evt_lst : Array = []
	for file in _event_files:
		evt_lst = []
		var fileheader : Array = dbm.db.select_rows("fileheader", "filename = '" + file + "'", ["Id"])
		if fileheader.size() > 0:
			var id = fileheader[0]
			for evt_typ in evt_types:
				evt_lst.append_array(dbm.db.select_rows(evt_typ, "FileheaderId = '" + String(id) + "'" , ["*"]).duplicate())
			
			if !evt_lst.empty():
				var cmdr_id = evt_lst[0]["CMDRId"]
				var cmdr = dbm.db.select_rows("Commander", "Id = '" + String(cmdr_id) + "'", ["*"])
				log_objects[file] = { "name": cmdr[0]["Name"], "FID": cmdr[0]["FID"], "dataobject": evt_lst.duplicate() }
	return log_objects

# For now this only retrieves from data not present in database
# so it's very specific function
func get_all_new_events_by_type(_event_types : Array, _new_log_events : Dictionary):
	var evt_lst : Array = []
	for log_file in _new_log_events.keys():
		var dobj = _new_log_events[log_file]["events"]
		evt_lst.append_array(get_events_by_type(_event_types, dobj))
	return evt_lst


