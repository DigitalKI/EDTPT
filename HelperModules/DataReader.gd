extends Node
class_name DataReader

var logs_path = "%s\\Saved Games\\Frontier Developments\\Elite Dangerous\\" % OS.get_environment('userprofile')
var thread_reader : Thread = null
var mutex
var cmdrs : Dictionary = {}
var logfiles : Array = []
var logobjects : Dictionary
var ships_manager : ShipsDataManager = ShipsDataManager.new()

#signal thread_completed_get_files
signal thread_completed_get_log_objects

func _ready():
	thread_reader = Thread.new()
	mutex = Mutex.new()
	print(logs_path)
#	get_all_log_objects_threaded()
	get_all_log_objects()
	
func _exit_tree():
	if thread_reader.is_active():
		thread_reader.wait_to_finish()

func get_files(_nullarg = null):
	var dir = Directory.new()
	if dir.open(logs_path) == OK:
		logobjects = {}
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				logobjects[file_name] = null
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
#	emit_signal("thread_completed_get_files")
#	emit_signal("reset_thread")
	
func get_files_threaded():
	thread_reader.start(self, "get_files", null)

func get_log_object(_filename : String):
	var file = File.new()
	var jjournal : JSONParseResult
	var results = []
	if file.open(logs_path + _filename, File.READ) == OK:
		var content : String
		while !file.eof_reached():
			if _filename.get_extension() == "json":
				content += file.get_line()
			else:
				content = file.get_line()
				if content:
					jjournal = JSON.parse(content)
					if jjournal.result:
						results.append(jjournal.result)
						
		if _filename.get_extension() == "json":
			if content:
				jjournal = JSON.parse(content)
				if jjournal.result:
					results.append(jjournal.result)
		file.close()
	return {"date_modified": file.get_modified_time(logs_path + _filename), "dataobject":results}

func get_all_log_objects(_nullparam = null):
	mutex.lock()
	get_files()
	var curr_logobj
	var total_files = logobjects.size()
	var current_file = 1
	for log_file in logobjects.keys():
		print("reading \"%s\" %s of %s"  % [log_file, current_file, total_files])
		current_file += 1
		curr_logobj = get_log_object(log_file)
#		Extracts the commanders name
		var curr_cmdr = get_events_by_type("Commander", curr_logobj["dataobject"], true)
		if curr_cmdr:
			cmdrs[curr_cmdr[0]["FID"]] = curr_cmdr[0]["Name"]
		logobjects[log_file] = curr_logobj.duplicate()
	ships_manager.get_stored_ships()
	ships_manager.get_ships_loadoud()
	print("Max jmp range: %s" % ships_manager.get_max_jump_range())
	mutex.unlock()
	call_deferred("reset_thread")

func get_all_log_objects_threaded():
	thread_reader.start(self, "get_all_log_objects", null)

func reset_thread():
	if thread_reader.is_active():
		thread_reader.wait_to_finish()
	emit_signal("thread_completed_get_log_objects")

func get_events_by_type(_event_type : String, _dataobject, _first : bool = false):
	var evt_lst : Array = []
	for evt in _dataobject:
		if evt is Dictionary && evt.has("event") && evt["event"] == _event_type:
			evt_lst.append(evt)
			if _first:
				break
	return evt_lst
	

func get_all_events_by_type(_event_type : String):
	var evt_lst : Array = []
	for log_file in logobjects.keys():
		var dobj = logobjects[log_file]["dataobject"]
		evt_lst.append_array(get_events_by_type(_event_type, dobj))
	return evt_lst
