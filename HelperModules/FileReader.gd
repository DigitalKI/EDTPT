# This script reads data from files.
# It will need to be cleaned,
# there shouldn't be need to pass all those parameters
extends Node
class_name FileReader

var default_logs_path = "%s\\Saved Games\\Frontier Developments\\Elite Dangerous\\" % OS.get_environment('userprofile')
var logs_path = ""

func check_logs_path(_current_scene : Node):
	if data_reader.settings_manager.get_setting("logs_path"):
		logs_path = data_reader.settings_manager.get_setting("logs_path")
	else:
		logs_path = default_logs_path
	var logs_dir = Directory.new()
	if !logs_dir.dir_exists(logs_path):
		return false
	else:
		return true

func set_custom_journal_path(_current_scene : Node):
	var nopath_dialog = AcceptDialog.new()
	nopath_dialog.window_title = "Journal logs path not found"
	nopath_dialog.dialog_text = "The journals path was not found, "
	nopath_dialog.dialog_text += "this might happen when the \"Saved Games\" directory is not located in a standard location."
	nopath_dialog.dialog_text += "\nPlease select it manually."
	nopath_dialog.dialog_autowrap = true
	_current_scene.add_child(nopath_dialog)
	var vp = _current_scene.get_viewport()
	print(vp.size)
	nopath_dialog.popup(Rect2(vp.size / 2 - vp.size / 8, vp.size / 4))
	nopath_dialog.connect("confirmed", self, "_open_file_dialog", [_current_scene])
	
func _open_file_dialog(_current_scene : Node):
	var file_dialog = FileDialog.new()
	_current_scene.add_child(file_dialog)
	file_dialog.filters = PoolStringArray(["*. ; 7Zip executable"])
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.mode = FileDialog.MODE_OPEN_DIR
	file_dialog.current_path = OS.get_environment('userprofile')
	file_dialog.current_dir = OS.get_environment('userprofile')
	file_dialog.window_title = "Select the journal logs path"
	file_dialog.connect("dir_selected", self, "_on_dir_selected")
	file_dialog.anchor_left = 0.5
	file_dialog.anchor_top = 0.5
	file_dialog.anchor_right = 0.5
	file_dialog.anchor_bottom = 0.5
	file_dialog.rect_min_size = Vector2(400, 300)
	file_dialog.margin_left = -file_dialog.rect_min_size.x / 2.0
	file_dialog.margin_top = -file_dialog.rect_min_size.y / 2.0
	file_dialog.show_modal()
	file_dialog.invalidate()

func _on_dir_selected(_dir):
	logs_path = _dir
	data_reader.settings_manager.save_setting("logs_path", logs_path)

func get_files(_get_cache := false):
	var _logfiles := []
	var dir = Directory.new()
	if dir.open(logs_path) == OK:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			elif _get_cache && file_name.get_extension() == "cache":
				_logfiles.append(file_name)
			elif file_name.begins_with("Journal."):
				_logfiles.append(file_name)
			file_name = dir.get_next()
	else:
		logger.log_event("An error occurred when trying to access the path.")
	return _logfiles

func get_file_size(_filename, _file : File = File.new()):
	var fliesize := 0
	var file_status = OK
	var have_to_close := false
	if !_file.is_open():
		file_status = _file.open(logs_path + _filename, File.READ)
		have_to_close = true
	if file_status == OK:
		fliesize = _file.get_len()
	if have_to_close:
		_file.close()
	return fliesize

func get_file_events(_filename : String, _seekto : int = 0):
	var file = File.new()
	var fliesize := 0
	var jjournal : JSONParseResult
	var f_events = []
	var cmdr = ""
	var fid = ""
	if !logs_path.ends_with("/"):
		logs_path += "/"
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
						logger.log_event("Problem with this file: %s" % _filename)
						logger.log_event("  Here: %s" % content)
		if _filename.get_extension() == "json":
			if content:
				jjournal = JSON.parse(content)
				if jjournal.result:
					f_events.append(jjournal.result)
		file.close()
	else:
		logger.log_event("Cannot read log file %s, status: %s" % [_filename, file_status])
	return {"name": cmdr, "FID" : fid, "filesize" : fliesize, "events": f_events}
