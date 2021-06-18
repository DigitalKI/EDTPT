extends Node
class_name DataReader

var logs_path = "%s\\Saved Games\\Frontier Developments\\Elite Dangerous\\" % OS.get_environment('userprofile')
var thread_reader : Thread = null
var mutex
var logfiles : Array = []
var logobjects : Dictionary = {}

#signal thread_completed_get_files
signal thread_completed_get_log_objects

func _ready():
	thread_reader = Thread.new()
	mutex = Mutex.new()
	get_all_log_objects_threaded()
#	get_all_log_objects()
	
func _exit_tree():
	if thread_reader.is_active():
		thread_reader.wait_to_finish()

func get_files(_nullarg = null):
	var dir = Directory.new()
	if dir.open(logs_path) == OK:
		logfiles = []
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				logfiles.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
#	emit_signal("thread_completed_get_files")
#	emit_signal("reset_thread")
	
func get_files_threaded():
	thread_reader.start(self, "get_files", null)

func get_log_object(_filename):
	var file = File.new()
	var jjournal : JSONParseResult
	var results = []
	if file.open(logs_path + _filename, File.READ) == OK:
		while !file.eof_reached():
			var content = file.get_line()
			if content:
				jjournal = JSON.parse(content)
				if jjournal.result:
					results.append(jjournal.result)
		file.close()
	return {"filename": _filename, "date_modified": file.get_modified_time(logs_path + _filename), "dataobject":results}

func get_all_log_objects(_nullparam = null):
	mutex.lock()
#	logobjects.clear()
	get_files()
	var curr_logobj
	for log_file in logfiles:
		curr_logobj = get_log_object(log_file)
		logobjects[curr_logobj["filename"]] = curr_logobj
	mutex.unlock()
	call_deferred("reset_thread")

func get_all_log_objects_threaded():
	thread_reader.start(self, "get_all_log_objects", null)

func reset_thread():
	if thread_reader.is_active():
		thread_reader.wait_to_finish()
	emit_signal("thread_completed_get_log_objects")
