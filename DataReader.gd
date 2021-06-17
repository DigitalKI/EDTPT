extends Node
class_name DataReader

var logs_path = "%s\\Saved Games\\Frontier Developments\\Elite Dangerous\\" % OS.get_environment('userprofile')
var thread_reader : Thread = null
var mutex
var logfiles : Array = []
var current_logobject = null

#signal thread_completed_get_files
signal thread_completed_get_log_objects

func _ready():
	thread_reader = Thread.new()
	mutex = Mutex.new()
#	if !self.is_connected("reset_thread", self, "_on_DataReader_reset_thread"):
#		self.connect("reset_thread", self, "_on_DataReader_reset_thread")
	
func _exit_tree():
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

func get_log_objects(_filename):
	var file = File.new()
	var jjournal : JSONParseResult
	var results = []
	mutex.lock()
	if file.open(logs_path + _filename, File.READ) == OK:
		while !file.eof_reached():
			var content = file.get_line()
			if content:
				jjournal = JSON.parse(content)
				results.append(jjournal.result)
		file.close()
	current_logobject = results
	mutex.unlock()
	call_deferred("reset_thread")
	
func get_log_objects_threaded(_filename):
	thread_reader.start(self, "get_log_objects", _filename)

#func read_log():
#	for logfile in get_files():
#		if logfile.get_extension() == 'log':
#			var logf = get_log_object(logfile)
#			print(logf)


func reset_thread():
	if thread_reader.is_active():
		thread_reader.wait_to_finish()
	emit_signal("thread_completed_get_log_objects")
