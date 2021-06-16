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

func get_log_objects(_filename):
	var file = File.new()
	var results = []
	if file.open(logs_path + _filename, File.READ) == OK:
		while !file.eof_reached():
			var jjournal : JSONParseResult
			var content = file.get_line()
			jjournal = JSON.parse(content)
			results.append(jjournal.result)
		file.close()
	return results

#func read_log():
#	for logfile in get_files():
#		if logfile.get_extension() == 'log':
#			var logf = get_log_object(logfile)
#			print(logf)

