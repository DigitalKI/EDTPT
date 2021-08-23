# This script is in charge of reading events from the log journals
# and write them to the database.
# It needs to be cleaned up a bit, it's already a bit messy.

extends Node
class_name DataReader

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db : SQLite

var db_creation_script := "res://Database/db_json_schema"
var db_path := "user://Database/"
var db_name := "edtpt"

var forbidden_columns := ["From", "To", "Group", "By", "Sort", "Asc"]
var not_usable_columns := ["Id", "ID"]
var logs_path = "%s\\Saved Games\\Frontier Developments\\Elite Dangerous\\" % OS.get_environment('userprofile')
var thread_reader : Thread = null
var mutex : Mutex
var selected_cmdr setget _set_cmdr
var current_cmdr : Dictionary = {}
var log_events : String = ""
var log_event_last : String = ""
var cmdrs : Dictionary = {}
var evt_types : Array = []
var events : Array = []
var logfiles : Array = []
var logobjects : Dictionary = {}
var new_log_events : Dictionary = {}
var cached_events : Array = []

var timer : Timer
onready var edsm_manager : edsmDataManager = edsmDataManager.new()
onready var ships_manager : ShipsDataManager = ShipsDataManager.new()
onready var galaxy_manager : GalaxyDataManager = GalaxyDataManager.new()

#signal thread_completed_get_files
signal thread_completed_get_log_objects
signal new_cached_events(new_events)

signal log_event_generated(log_text)

func _ready():
	thread_reader = Thread.new()
	mutex = Mutex.new()
	log_event(logs_path)
	
	# Some nodes that are inside data managers need to be added to a node tree
	# We do it programmatically so that we don't need a scene for them
	var current_scene = get_tree().current_scene
	
	# First one is the HttpRequest node
	edsm_manager.add_html_reader()
	current_scene.add_child(edsm_manager.http_request)
	
	# The second is the timer
	timer = Timer.new()
	current_scene.add_child(timer)
	timer.wait_time = 5
	timer.connect("timeout", self, "timer_read_cache")
#	timer.start()
	prepare_database()
	# This shouldn't be here, but it's for dev purposes
#	clean_database()
	
	var curr_cmdrs = db.select_rows("Commander", "", ["*"])
	if !curr_cmdrs.empty():
		current_cmdr = curr_cmdrs[0]
	
	thread_reader.start(self, "journal_updates", null)
#	journal_updates()

func _exit_tree():
	db.close_db()
	if thread_reader.is_active():
		thread_reader.wait_to_finish()

func _set_cmdr(_value):
	var cmdr_res = db.select_rows("Commander", "name = " + _value, ["*"])
	if !cmdr_res.empty():
		current_cmdr = cmdr_res[0]

func timer_read_cache():
	update_events_from_last_log_threaded()

func journal_updates(_nullparam = null):
	update_events_from_last_log()
	write_new_events()

func write_new_events(_nullparam = null):
	mutex.lock()
	get_new_log_objects()
	write_all_events_to_db()
	get_event_types()
	mutex.unlock()
	call_deferred("reset_thread")

func log_event(_text):
	log_event_last = _text
	log_events += _text + "\n"
	self.emit_signal("log_event_generated", _text)
	print(log_event_last)

func prepare_database(_verbose : bool = false):
	var result := true
	var dir : Directory = Directory.new()
	if !dir.dir_exists(db_path):
		dir.make_dir(db_path)
	
	db = SQLite.new()
	db.path = "user://Database/edtpt"
	db.verbose_mode = _verbose
	# Open the database using the db_name found in the path variable
	db.open_db()
#	db.export_to_json("user://Database/edtpt_jsnbkp")
	if db.select_rows("sqlite_master", "type = 'table'", ["*"]).empty():
		result = db.import_from_json(db_creation_script)
	return result

func clean_database():
	var tables = db.select_rows("sqlite_master", "type = 'table'", ["*"]).duplicate()
	for table in tables:
		if table["name"] != "sqlite_sequence" && table["name"] != "Commander" && table["name"] != "Fileheader" && table["name"] != "event_types":
			if db.drop_table(table["name"]):
				log_event("Dropping table %s" % table["name"])
			else:
				log_event("Could not delete table %s" % table["name"])
	db.delete_rows("Commander","")
	db.delete_rows("Fileheader","")
	db.delete_rows("event_types","")
	var selected_rows = db.select_rows("sqlite_sequence", "", ["*"])
	for seq in selected_rows:
		seq["seq"] = 0
		db.update_rows("sqlite_sequence", "name = '" + seq["name"] + "'", seq)
	db.query("VACUUM;")
	db.query("CREATE TABLE IF NOT EXISTS Backpack (Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,CMDRId INTEGER NOT NULL,FileheaderId INTEGER NOT NULL,'timestamp' text,'Items' text,'Components' text,'Consumables' text,'Data' text);")
	# I should also add a counter reset for the autoincrement fields

func db_get_log_files(_filter = ""):
	var selected_array = db.select_rows("Fileheader", _filter, ["*"])
	return selected_array

func db_get_last_logfile():
	db.query("SELECT * FROM Fileheader ORDER BY filename desc LIMIT 1;")
	return db.query_result.duplicate()

func db_get_all_cmdrs():
	var selected_array = db.select_rows("Commander", "", ["*"])
	for cmdr in selected_array:
		cmdrs[cmdr["FID"]] = cmdr["Name"]
	return cmdrs

func db_set_event_type(_event_type):
	# Create the event type
	if db.select_rows("event_types", "event_type = '" + _event_type + "'", ["*"]).empty():
		if !db.insert_rows("event_types", [{"event_type": _event_type}]):
			log_event("There was a problem adding a new event type")

# Creates a table from the event type, 
# automatically generating columns with its respective type.
# Table is not created if it already exists in the database.
func db_create_table_from_event(_event : Dictionary):
	var table_name = _event["event"]
	db_set_event_type(table_name)
	# Do not create if exists already
	if db.select_rows("sqlite_master", "type = 'table' AND name='"+ table_name + "'", ["*"]).empty():
		#Let's get the event with most rows, as some new where added and we need the most up-to-date
		var typed_events = get_all_new_events_by_type([table_name])
		var example_event : Dictionary = {}
		for evt in typed_events:
			for evt_k in evt.keys():
				if !example_event.has(evt_k):
					example_event[evt_k] = evt[evt_k] if evt[evt_k] else "string"
		var table_dict : Dictionary = {}
		table_dict["Id"] = {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment" : true}
		table_dict["CMDRId"] = {"data_type":"int", "not_null": true}
		table_dict["FileheaderId"] = {"data_type":"int", "not_null": true}
		
		for column in example_event.keys():
			if column != "event":
				var data_type = "text"
				if example_event[column] is String && (example_event[column] == "true" ||  example_event[column] == "false"):
					data_type = "int"
#				elif typeof(example_event[column]) == TYPE_ARRAY:
#					data_type = "blob"
				elif typeof(example_event[column]) == TYPE_INT:
					data_type = "int"
				elif typeof(example_event[column]) == TYPE_REAL:
					data_type = "numeric"
				
				# Apparently this column name cannot work
				# We add single quotes
				# forbidden_columns is defined at the beginning of this script
				# , as we're gong to use it for inserts too
				if forbidden_columns.has(column):
					table_dict["'" + column + "'"] = {"data_type": data_type}
				elif not_usable_columns.has(column):
					table_dict[column + "_" + column] = {"data_type": data_type}
				else:
					table_dict[column] = {"data_type": data_type}
		
		return db.create_table(table_name, table_dict)
	else:
		return false

func get_files(_get_cache := false):
	var dir = Directory.new()
	if dir.open(logs_path) == OK:
		logfiles.clear()
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
#				log_event("Found directory: " + file_name)
			elif _get_cache && file_name.get_extension() == "cache":
				logfiles.append(file_name)
			elif file_name.begins_with("Journal."):
				logfiles.append(file_name)
			file_name = dir.get_next()
	else:
		log_event("An error occurred when trying to access the path.")
	return logfiles

func get_files_threaded():
	if !thread_reader.is_active():
		thread_reader.start(self, "get_files", null)

func get_file_events(_filename : String):
	var file = File.new()
	var jjournal : JSONParseResult
	var f_events = []
	var cmdr = ""
	var fid = ""
	var file_status = file.open(logs_path + _filename, File.READ)
	if file_status == OK:
		var content : String = ""
		while !file.eof_reached():
			if _filename.get_extension() == "json":
				content += file.get_line()
			else:
				content = file.get_line()
				if content:
					jjournal = JSON.parse(content)
					if jjournal.result is Dictionary:
						# If Commander event is found and does not exists
						# it is added to the table as new record
						if jjournal.result["event"] == "Commander":
							cmdr = jjournal.result["Name"]
							fid = jjournal.result["FID"]
							if db.select_rows("Commander", "FID = '" + fid + "'", ["*"]).empty():
								if !db.insert_rows("Commander", [
									{"FID": fid, "name": cmdr}
								]):
									log_event("There was a problem adding a new CMDR")
						f_events.append(jjournal.result)
					else:
						log_event("Problem with this file: %s" % _filename)
						log_event("Here: %s" % content)
		if _filename.get_extension() == "json":
			if content:
				jjournal = JSON.parse(content)
				if jjournal.result:
					f_events.append(jjournal.result)
		file.close()
	else:
		log_event("Cannot read log file %s, status: %s" % [_filename, file_status])
	return {"name": cmdr, "FID" : fid, "events": f_events}

func get_new_log_objects(_nullparam = null):
	get_files()
	var total_files = logfiles.size()
	var total_events = 0
	var current_file = 1
	for log_file in logfiles:
		var parsed_logfiles = db_get_log_files("filename = '" + log_file + "'")
		if parsed_logfiles.empty():
			log_event("reading \"%s\" %s of %s"  % [log_file, current_file, total_files])
			current_file += 1
			var curr_logobj = get_file_events(log_file)
	#		updates the CMDRS list
			if curr_logobj["name"]:
				cmdrs[curr_logobj["FID"]] = curr_logobj["name"]
				if !selected_cmdr:
					selected_cmdr = curr_logobj["name"]
			new_log_events[log_file] = curr_logobj.duplicate()
			total_events += new_log_events[log_file]["events"].size()
#		else:
#			log_event("Journal already in database, skipped.")
	print("total events : %s" % total_events)

func write_all_events_to_db(_nullparam = null):
	var all_insert_events := {}
	for log_file in new_log_events.keys():
		if log_file.begins_with("Journal."):
			var fid = new_log_events[log_file]["FID"]
			var dobj = new_log_events[log_file]["events"]
			get_insert_events_from_object(dobj, fid, log_file, all_insert_events)
	# Ready to insert values!
	for table_name in all_insert_events.keys():
		log_event("Adding %s events of type %s" % [all_insert_events[table_name].size(), table_name])
		if !db.insert_rows(table_name, all_insert_events[table_name]):
			log_event("There was a problem adding event for table %s" % table_name)
	new_log_events.clear()

func get_insert_events_from_object(_dobj : Array, _fid : String, _log_file_name, _all_insert_events : Dictionary = {}):
	if _log_file_name.begins_with("Journal."):
		var fileheader : Dictionary = {}
		var fileheader_last_id = 0
		for header_evt in get_events_by_type(["Fileheader"], _dobj, true):
			fileheader = header_evt
			fileheader["filename"] = _log_file_name
		if !fileheader.empty():
			var existing_fileheader = db.select_rows("Fileheader", "filename = '" + _log_file_name + "'", ["*"])
			if existing_fileheader.empty():
				db.insert_row("Fileheader",
				{"part": fileheader["part"]
				, "language": fileheader["language"]
				, "Odyssey": fileheader["Odyssey"] if fileheader.has("Odyssey") else 0
				, "gameversion": fileheader["gameversion"]
				, "build": fileheader["build"]
				, "filename": fileheader["filename"]
				})
				fileheader_last_id = db.last_insert_rowid
			else:
				fileheader_last_id = existing_fileheader[0]["Id"]
		else:
			log_event("Fileheader not found! Skipping log file.")
		var cmdr_id_result = db.select_rows("Commander", "FID = '" + _fid + "'", ["*"])
		if !cmdr_id_result.empty():
			var cmdr_id = cmdr_id_result[0]["Id"]
			var event_tables = get_all_event_tables()
			for evt in _dobj:
				if evt is Dictionary && evt.has("event"):
					# Creates the event type table, but not for commander and fileheader, that are there by default
					var current_event_type = evt["event"]
					if !_all_insert_events.has(current_event_type):
						_all_insert_events[current_event_type] = []
					if !event_tables.has(current_event_type) && current_event_type != "Commander" && current_event_type != "Fileheader":
						if !db_create_table_from_event(evt):
							log_event("There was an error creating table %s" % current_event_type)
							log_event("Problem creating table %s" % current_event_type)
						#If you just createad a new event type table, then refresh the list of them
						event_tables = get_all_event_tables()
					if fileheader_last_id <= 0:
						log_event("No fileheader id to use! Aborting")
						continue
					if current_event_type != "Commander" && current_event_type != "Fileheader":
						# Removing event column as each type goes into a separate table
						evt.erase("event")
						#CNDRId and FileheaderId are added and assigned
						evt["CMDRId"] = cmdr_id
						evt["FileheaderId"] = fileheader_last_id
						# we now assign the appropriate value to certain fields
						# such as true/false, Dictionary, Array
						for col_key in evt.keys():
							if evt[col_key] is Array:
								evt[col_key] = JSON.print(evt[col_key])
							elif evt[col_key] is Dictionary:
								evt[col_key] = JSON.print(evt[col_key])
							elif evt[col_key] is String:
								if evt[col_key] == "false":
									evt[col_key] = 0
								elif evt[col_key] == "true":
									evt[col_key] = 1
							
							# Some columns have to be changed as they are reserved keywords or already used
							# leave this code last, as it is iterating through the columns
							if forbidden_columns.has(col_key):
								evt["'" + col_key + "'"] = evt[col_key]
								evt.erase(col_key)
							elif not_usable_columns.has(col_key):
								evt[col_key + "_" + col_key] = evt[col_key]
								evt.erase(col_key)
						_all_insert_events[current_event_type].append(evt)
	return _all_insert_events

func update_events_from_last_log_threaded():
	if !thread_reader.is_active():
		thread_reader.start(self, "update_events_from_last_log", null)

func update_events_from_last_log(_nullparam = null):
	mutex.lock()
	var lf : Array = db_get_last_logfile()
	var new_events = []
	if !lf.empty():
		var evts = get_file_events(lf[0]["filename"])
		var insert_events : Dictionary = get_insert_events_from_object(evts["events"], evts["FID"], lf[0]["filename"])
		# Ready to insert values!
		for table_name in insert_events.keys():
			for evt in insert_events[table_name]:
				# checks for existing data based on type and timestamp,
				# this should be reliable enough to avoid duplicates or loosing events
				# yet, it should be checked if FSSSignalDiscovered isn't affected,
				# timestamps are identical for each time it is triggered,
				# yet, as thy are triggered simultaneously, they al should be logged alltogether.
				var existing_data = db.select_rows(table_name, "timestamp = '%s'" % evt["timestamp"], ["*"])
				if existing_data.empty():
					new_events.append(evt)
					db.insert_row(table_name, evt)
					log_event("Adding event of type %s with timestamp %s" % [table_name, evt["timestamp"]])
		new_events.sort_custom(EventsSorter, "sort_ascending")
	mutex.unlock()
	call_deferred("reset_new_cached_events_thread", new_events)

func reset_new_cached_events_thread(_new_events):
	if thread_reader.is_active():
		thread_reader.wait_to_finish()
	emit_signal("new_cached_events", _new_events)

func get_all_event_tables():
	var table_evt_types := []
	for evt_tbl in db.select_rows("sqlite_master", "type = 'table'", ["*"]):
		table_evt_types.append(evt_tbl["name"])
	return table_evt_types

func reset_thread():
	if thread_reader.is_active():
		thread_reader.wait_to_finish()
	emit_signal("thread_completed_get_log_objects")

func get_event_types():
	evt_types = []
	var result = db.select_rows("event_types", "", ["event_type"])
	if !result.empty():
		for evt_tp in result:
			evt_types.append(evt_tp["event_type"])
	else:
		log_event("There was an error getting event types.")
	evt_types.sort()
	return evt_types

func get_events_by_type(_event_types : Array, _dataobject, _first : bool = false):
	var evt_lst : Array = []
	for evt in _dataobject:
		if evt is Dictionary && evt.has("event") && _event_types.has(evt["event"]):
			evt_lst.append(evt)
			if _first:
				break
	return evt_lst

# For now this only retrieves from data not present in database
# so it's very specific function
func get_all_new_events_by_type(_event_types : Array):
	var evt_lst : Array = []
	for log_file in new_log_events.keys():
		var dobj = new_log_events[log_file]["events"]
		evt_lst.append_array(get_events_by_type(_event_types, dobj))
	return evt_lst

func get_all_db_events_by_type(_event_types : Array, _amount : int = 1000, _range : int = 0, _timestart = "", _timeend = "") -> Array:
	var evt_lst : Array = []
	var current_amount = (" LIMIT " + String(_range)) if _amount > 0 else ""
	var current_range = "" if _amount == 0 else (", " + String(_amount))
	for evt_typ in _event_types:
		if !db.select_rows("sqlite_master", "type = 'table' AND name='"+ evt_typ + "'", ["*"]).empty():
			var table_select = "SELECT '" + evt_typ + "' as event, tbl.* FROM " + evt_typ + " AS tbl WHERE 1=1"
			if _timestart:
				table_select += " AND timestamp >= '" +_timestart + "'"
			if _timeend:
				table_select += " AND timestamp <= '" +_timeend + "'"
				
			table_select += " order by timestamp desc"
			table_select +=  current_amount + current_range
			db.query(table_select)
			evt_lst.append_array(db.query_result.duplicate())
	evt_lst.sort_custom(EventsSorter, "sort_ascending")
	return evt_lst

func get_all_db_events_by_file(_event_files : Array):
	var evt_lst : Array = []
	for file in _event_files:
		evt_lst = []
		var fileheader : Array = db.select_rows("fileheader", "filename = '" + file + "'", ["Id"])
		if fileheader.size() > 0:
			var id = fileheader[0]
			for evt_typ in evt_types:
				evt_lst.append_array(db.select_rows(evt_typ, "FileheaderId = '" + String(id) + "'" , ["*"]).duplicate())
			
			if !evt_lst.empty():
				var cmdr_id = evt_lst[0]["CMDRId"]
				var cmdr = db.select_rows("Commander", "Id = '" + String(cmdr_id) + "'", ["*"])
				logobjects[file] = { "name": cmdr[0]["Name"], "FID": cmdr[0]["FID"], "dataobject": evt_lst.duplicate() }
	return logobjects

class EventsSorter:
	static func sort_ascending(a, b):
		if a["timestamp"] < b["timestamp"]:
			return true
		return false
	static func sort_descending(a, b):
		if a["timestamp"] > b["timestamp"]:
			return true
		return false

class Sorter:
	var key_sorter = ""
	func _init(_key : String = "timestamp"):
		key_sorter = _key
	func sort_ascending(a, b):
		if a[key_sorter] < b[key_sorter]:
			return true
		return false
	func sort_descending(a, b):
		if a[key_sorter] > b[key_sorter]:
			return true
		return false

func sort_by_key(_array : Array, _key : String, _desc : bool = 1):
	var _sorter = Sorter.new(_key)
	_array.sort_custom(_sorter, "sort_descending" if _desc else "sort_ascending")

# this function gets a string value even when data is null
func get_value(_value):
	var string_value = "null" if (_value == null) else String(_value)
	return string_value
