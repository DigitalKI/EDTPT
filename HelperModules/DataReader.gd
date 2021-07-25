extends Node
class_name DataReader

var logs_path = "%s\\Saved Games\\Frontier Developments\\Elite Dangerous\\" % OS.get_environment('userprofile')
var thread_reader : Thread = null
var mutex
var cmdrs : Dictionary = {}
var selected_cmdr
var evt_types : Array = []
var logfiles : Array = []
var logobjects : Dictionary = {}
var ships_manager : ShipsDataManager = ShipsDataManager.new()
var galaxy_manager : GalaxyDataManager = GalaxyDataManager.new()

#signal thread_completed_get_files
signal thread_completed_get_log_objects

func _ready():
	thread_reader = Thread.new()
	mutex = Mutex.new()
	print(logs_path)
#	get_all_log_objects_threaded()
	get_all_log_objects()
	get_event_types()
	
func _exit_tree():
	if thread_reader.is_active():
		thread_reader.wait_to_finish()

func get_files(_nullarg = null):
	var dir = Directory.new()
	if dir.open(logs_path) == OK:
		logobjects = {}
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				logobjects[file_name] = []
				if file_name.begins_with("Journal."):
					logfiles.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
#	emit_signal("thread_completed_get_files")
#	emit_signal("reset_thread")
	
func get_files_threaded():
	thread_reader.start(self, "get_files", null)

func get_log_object(_filename : String):
	var attempt = 0
	var file = File.new()
	var jjournal : JSONParseResult
	var results = []
	var cmdr = ""
	var fid = ""
	var file_status = file.open(logs_path + _filename, File.READ)
	if file_status != OK:
		file.flush()
		print("Flushing file")
		file_status = file.open(logs_path + _filename, File.READ)
	if file_status == OK:
		var content : String
		while !file.eof_reached():
			if _filename.get_extension() == "json":
				content += file.get_line()
			else:
				content = file.get_line()
				if content:
					jjournal = JSON.parse(content)
					if jjournal.result is Dictionary:
						if jjournal.result["event"] == "Commander":
							cmdr = jjournal.result["Name"]
							fid = jjournal.result["FID"]
						results.append(jjournal.result)
					else:
						print("Problem with this file: %s" % _filename)
						print("Here: %s" % content)
		if _filename.get_extension() == "json":
			if content:
				jjournal = JSON.parse(content)
				if jjournal.result:
					results.append(jjournal.result)
		file.close()
	else:
		print("Cannot read log file, status: %s" % file_status)
	return {"date_modified": file.get_modified_time(logs_path + _filename), "name": cmdr, "FID": fid, "dataobject":results}

func get_all_log_objects(_nullparam = null):
	mutex.lock()
	get_files()
	var total_files = logobjects.size()
	var current_file = 1
	for log_file in logobjects.keys():
		print("reading \"%s\" %s of %s"  % [log_file, current_file, total_files])
		current_file += 1
		var curr_logobj = get_log_object(log_file)
#		Extracts the commanders name
		var curr_cmdr = get_events_by_type(["Commander"], curr_logobj["dataobject"], true)
		if curr_cmdr:
			cmdrs[curr_cmdr[0]["FID"]] = curr_cmdr[0]["Name"]
			if !selected_cmdr:
				selected_cmdr = curr_cmdr[0]["Name"]
		logobjects[log_file] = curr_logobj
	ships_manager.get_stored_ships()
	ships_manager.get_ships_loadoud()
	mutex.unlock()
	call_deferred("reset_thread")

func get_all_log_objects_threaded():
	thread_reader.start(self, "get_all_log_objects", null)

func reset_thread():
	if thread_reader.is_active():
		thread_reader.wait_to_finish()
	emit_signal("thread_completed_get_log_objects")

func get_event_types():
	evt_types = []
	for log_file in logobjects.keys():
		var dobj = logobjects[log_file]["dataobject"]
		for evt in dobj:
			if evt is Dictionary && evt.has("event") && !evt_types.has(evt["event"]):
				evt_types.append(evt["event"])
	return evt_types

func get_events_by_type(_event_types : Array, _dataobject, _first : bool = false):
	var evt_lst : Array = []
	for evt in _dataobject:
		if evt is Dictionary && evt.has("event") && _event_types.has(evt["event"]):
			evt_lst.append(evt)
			if _first:
				break
	return evt_lst

func get_all_events_by_type(_event_types : Array):
	var evt_lst : Array = []
	for log_file in logobjects.keys():
		var dobj = logobjects[log_file]["dataobject"]
		evt_lst.append_array(get_events_by_type(_event_types, dobj))
	return evt_lst

