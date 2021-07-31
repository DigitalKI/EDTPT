extends Node
class_name DataReader

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db

var forbidden_columns := ["From", "To", "Group", "By", "Sort", "Asc"]
var not_usable_columns := ["Id", "ID"]
var logs_path = "%s\\Saved Games\\Frontier Developments\\Elite Dangerous\\" % OS.get_environment('userprofile')
var thread_reader : Thread = null
var mutex
var log_events : String = ""
var log_event_last : String = ""
var cmdrs : Dictionary = {}
var current_cmdr : Dictionary = {}
var selected_cmdr
var evt_types : Array = []
var logfiles : Array = []
var logobjects : Dictionary = {}
var new_log_events : Dictionary = {}
var ships_manager : ShipsDataManager = ShipsDataManager.new()
var galaxy_manager : GalaxyDataManager = GalaxyDataManager.new()

#signal thread_completed_get_files
signal thread_completed_get_log_objects

signal log_event_generated(log_text)

func _ready():
	thread_reader = Thread.new()
	mutex = Mutex.new()
	log_event(logs_path)
	
	db = SQLite.new()
	db.path = "res://Database/edtpt"
#	db.verbose_mode = true
	# Open the database using the db_name found in the path variable
	db.open_db()
	
	# This shouldn't be here, but it's for dev purposes
	clean_database()
	
	get_new_log_objects()
	write_events_to_db()
#	get_all_log_objects_threaded()
#	get_event_types()
#	get_all_log_objects()
	ships_manager.get_stored_ships()
	ships_manager.get_ships_loadoud()

func _exit_tree():
	db.close_db()
	if thread_reader.is_active():
		thread_reader.wait_to_finish()

func log_event(_text):
	log_event_last = _text
	log_events += _text + "\n"
	self.emit_signal("log_event_generated", _text)

func clean_database():
	var tables = db.select_rows("sqlite_master", "type = 'table'", ["*"]).duplicate()
	for table in tables:
		if table["name"] != "sqlite_sequence" && table["name"] != "Commander" && table["name"] != "Events" && table["name"] != "Fileheader":
			if db.drop_table(table["name"]):
				log_event("Dropping table %s" % table["name"])
			else:
				log_event("Could not delete table %s" % table["name"])
	db.delete_rows("Events","")
	db.delete_rows("Commander","")
	db.delete_rows("Fileheader","")
	db.query("VACUUM;")
	# I should also add a counter reset for the autoincrement fields


func db_get_log_files(_filter = ""):
	var selected_array = db.select_rows("Fileheader", _filter, ["*"])
	return selected_array

# Creates a table from the event type, 
# automatically generating columns with its respective type.
# Table is not created if it already exists in the database.
func db_create_table_from_event(_event : Dictionary):
	var table_name = _event["event"]
	# Do not create if exists already
	if db.select_rows("sqlite_master", "type = 'table' AND name='"+ table_name + "'", ["*"]).empty():
		
		#Let's get the event with most rows, as some new where added and we need the most up-to-date
		var typed_events = get_all_events_by_type([table_name])
		var example_event : Dictionary = {}
		for evt in typed_events:
			for evt_k in evt.keys():
				if !example_event.has(evt_k):
					example_event[evt_k] = evt[evt_k] if evt[evt_k] else "string"
		var table_dict : Dictionary = Dictionary()
		table_dict["Id"] = {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment" : true}
		table_dict["EventId"] = {"data_type":"int", "not_null": true}
		
		for column in example_event.keys():
			if column != "timestamp" && column != "event":
				var data_type = "text"
				if example_event[column] is String && (example_event[column] == "true" ||  example_event[column] == "false"):
					data_type = "int"
				elif typeof(example_event[column]) == TYPE_ARRAY:
					data_type = "blob"
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
		
		if table_name == "Backpack":
			print("here")
#			table_dict["Message_Localised"] = {"data_type":"text"}
		return db.create_table(table_name, table_dict)
	else:
		return false

func get_files(_nullarg = null):
	var dir = Directory.new()
	if dir.open(logs_path) == OK:
		logfiles.clear()
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				log_event("Found directory: " + file_name)
			else:
				if file_name.begins_with("Journal."):
					logfiles.append(file_name)
			file_name = dir.get_next()
	else:
		log_event("An error occurred when trying to access the path.")
	return logfiles

func get_files_threaded():
	thread_reader.start(self, "get_files", null)

func get_file_events(_filename : String):
	var file = File.new()
	var jjournal : JSONParseResult
	var events = []
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
						events.append(jjournal.result)
					else:
						log_event("Problem with this file: %s" % _filename)
						log_event("Here: %s" % content)
		if _filename.get_extension() == "json":
			if content:
				jjournal = JSON.parse(content)
				if jjournal.result:
					events.append(jjournal.result)
		file.close()
	else:
		log_event("Cannot read log file, status: %s" % file_status)
	return {"name": cmdr, "FID" : fid, "events": events}

func get_new_log_objects(_nullparam = null):
	mutex.lock()
	get_files()
	var total_files = logfiles.size()
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
		else:
			log_event("Journal already in database, skipped.")
	mutex.unlock()
	call_deferred("reset_thread")

func write_events_to_db():
	var all_insert_events := {}
	for log_file in new_log_events.keys():
		if log_file.begins_with("Journal."):
			var fid = new_log_events[log_file]["FID"]
			var dobj = new_log_events[log_file]["events"]
			var fileheader : Dictionary = {}
			var fileheader_last_id = 0
			for header_evt in get_events_by_type(["Fileheader"], dobj):
				fileheader = header_evt
				fileheader["filename"] = log_file
			if !fileheader.empty():
				var ir = db.insert_row("Fileheader",
				{"part": fileheader["part"]
				, "language": fileheader["language"]
				, "Odyssey": fileheader["Odyssey"] if fileheader.has("Odyssey") else 0
				, "gameversion": fileheader["gameversion"]
				, "build": fileheader["build"]
				, "filename": fileheader["filename"]
				})
				fileheader_last_id = db.last_insert_rowid
			else:
				print("Fileheader not found! Corruption?")
			var cmdr_id_result = db.select_rows("Commander", "FID = '" + fid + "'", ["*"])
			if !cmdr_id_result.empty():
				var cmdr_id = cmdr_id_result[0]["Id"]
				var event_tables = get_all_event_tables()
				for evt in dobj:
					if evt is Dictionary && evt.has("event"):
						# Creates the event type table, but not for commander and fileheader, that are there by default
						var current_event_type = evt["event"]
						if !event_tables.has(current_event_type) && current_event_type != "Commander" && current_event_type != "Fileheader":
							if !db_create_table_from_event(evt):
								log_event("There was an error creating table %s" % current_event_type)
								print("Problem creating table %s" % current_event_type)
							if current_event_type == "Backpack":
								print("here")
							#If you just createad a new event type table, then refresh the list of them
							event_tables = get_all_event_tables()
						if fileheader_last_id <= 0:
							print("No fileheader id to use! Aborting")
							continue
						if current_event_type != "Commander" && current_event_type != "Fileheader":
							all_insert_events[current_event_type] = []
							if !db.insert_row("Events", {
								"timestamp": evt["timestamp"]
								, "event": current_event_type
								, "CMDRId": cmdr_id
								, "FileheaderId": fileheader_last_id
								}):
								log_event("There was a problem adding the new event to table 'Events'.")
							evt["EventId"] = db.last_insert_rowid
							evt.erase("timestamp")
							evt.erase("event")
							for col_key in evt.keys():
								if evt[col_key] is Array:
									evt[col_key] = PoolByteArray(evt[col_key])
								elif evt[col_key] is Dictionary:
									evt[col_key] = String(evt[col_key]).to_ascii()
								elif evt[col_key] is String:
									if evt[col_key] == "false":
										evt[col_key] = 0
									elif evt[col_key] == "true":
										evt[col_key] = 1
								elif (current_event_type == "Commander" || current_event_type == "Fileheader") && col_key == "EventId":
									evt.erase(col_key)
								
								# Some columns have to be changed as they are reserved keywords or already used
								# leave this code last, as it is iterating through the columns
								if forbidden_columns.has(col_key):
									evt["'" + col_key + "'"] = evt[col_key]
									evt.erase(col_key)
								elif not_usable_columns.has(col_key):
									evt[col_key + "_" + col_key] = evt[col_key]
									evt.erase(col_key)
							all_insert_events[current_event_type].append(evt)
				
		for table_name in all_insert_events.keys():
			if !db.insert_rows(table_name, all_insert_events[table_name]):
				log_event("There was a problem adding event for table %s" % table_name)
		all_insert_events = {}

func get_all_event_tables():
	var table_evt_types := []
	for evt_tbl in db.select_rows("sqlite_master", "type = 'table'", ["*"]):
		table_evt_types.append(evt_tbl["name"])
	return table_evt_types

func get_all_log_objects_threaded():
	thread_reader.start(self, "get_all_log_objects", null)

func reset_thread():
	if thread_reader.is_active():
		thread_reader.wait_to_finish()
	emit_signal("thread_completed_get_log_objects")

func get_event_types():
	evt_types = []
	if db.query("SELECT DISTINCT event FROM 'Events' ORDER BY event;"):
		var result = db.query_result.duplicate()
		for evt_tp in result:
			evt_types.append(evt_tp["event"])
	else:
		log_event("There was an error getting event types.")
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
func get_all_events_by_type(_event_types : Array):
	var evt_lst : Array = []
	for log_file in new_log_events.keys():
		var dobj = new_log_events[log_file]["events"]
		evt_lst.append_array(get_events_by_type(_event_types, dobj))
	return evt_lst

func get_all_db_events_by_type(_event_types : Array):
	var evt_lst : Array = []
	for evt_typ in _event_types:
		if !db.select_rows("sqlite_master", "type = 'table' AND name='"+ evt_typ + "'", ["*"]).empty():
			var events : Array = db.select_rows(evt_typ, "", ["*"])
			evt_lst.append_array(events)
	return evt_lst

