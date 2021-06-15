extends Node

var logs_path = "%s\\Saved Games\\Frontier Developments\\Elite Dangerous\\" % OS.get_environment('userprofile')

func get_files() -> Array:
	var logfiles : Array = []
	var dir = Directory.new()
	if dir.open(logs_path) == OK:
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
	return logfiles

func get_log_variant(_filename):
	var file = File.new()
	var jjournal : JSONParseResult
	if file.open(logs_path + _filename, File.READ) == OK:
		while !file.eof_reached():
			var content = file.get_line()
			jjournal = JSON.parse(content)
		file.close()
	return jjournal.result

func read_log():
	for logfile in get_files():
		if logfile.get_extension() == 'log':
			var logf = get_log_variant(logfile)
			print(logf)

