# This script reads data from files.
# It will need to be cleaned,
# there shouldn't be need to pass all those parameters
extends Node
class_name FileReader

var logs_path = "%s\\Saved Games\\Frontier Developments\\Elite Dangerous\\" % OS.get_environment('userprofile')

func get_files(_get_cache := false):
	var _logfiles := []
	var dir = Directory.new()
	if dir.open(logs_path) == OK:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
#				logger.log_event("Found directory: " + file_name)
			elif _get_cache && file_name.get_extension() == "cache":
				_logfiles.append(file_name)
			elif file_name.begins_with("Journal."):
				_logfiles.append(file_name)
			file_name = dir.get_next()
	else:
		data_reader.log_event("An error occurred when trying to access the path.")
	return _logfiles

func get_file_size(_filename, _file : File = File.new()):
	var fliesize := 0
	var file_status = OK
	if !_file.is_open():
		file_status = _file.open(logs_path + _filename, File.READ)
	if file_status == OK:
		fliesize = _file.get_len()
	return fliesize

func get_file_events(_filename : String, _seekto : int = 0):
	var file = File.new()
	var fliesize := 0
	var jjournal : JSONParseResult
	var f_events = []
	var cmdr = ""
	var fid = ""
	var file_status = file.open(logs_path + _filename, File.READ)
	if file_status == OK:
		fliesize = file.get_len()
		file.seek(_seekto)
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
						f_events.append(jjournal.result)
					else:
						data_reader.log_event("Problem with this file: %s" % _filename)
						data_reader.log_event("Here: %s" % content)
		if _filename.get_extension() == "json":
			if content:
				jjournal = JSON.parse(content)
				if jjournal.result:
					f_events.append(jjournal.result)
		file.close()
	else:
		data_reader.log_event("Cannot read log file %s, status: %s" % [_filename, file_status])
	return {"name": cmdr, "FID" : fid, "filesize" : fliesize, "events": f_events}
