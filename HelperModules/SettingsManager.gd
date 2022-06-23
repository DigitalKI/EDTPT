extends Object
class_name SettingsManager

var settings_path : String = "user://settings"
var settings_file : File = File.new()

func _init():
	var settings_directory : Directory = Directory.new()
	var settings_file : File = File.new()
	if !settings_directory.dir_exists(settings_path):
		settings_directory.make_dir(settings_path)
	if ! settings_file.file_exists(settings_path + "/settings.json"):
		settings_file.open(settings_path + "/settings.json", File.WRITE)
		settings_file.close()

func save_setting(_key : String, _value):
	var json_settings = {}
	var settings_strig := ""
	if settings_file.open(settings_path + "/settings.json", File.READ_WRITE) == OK:
		settings_strig = settings_file.get_as_text()
		var json_settings_parser = JSON.parse(settings_strig)
		if json_settings_parser.error == OK:
			json_settings = json_settings_parser.result
		settings_file.close()
	# We close and open again the settings file in order to use the WRITE mode
	if settings_file.open(settings_path + "/settings.json", File.WRITE) == OK:
		json_settings[_key] = var2str(_value) if !(_value is Dictionary) else _value
		settings_strig = JSON.print(json_settings, "  ", true)
		settings_file.store_string(settings_strig)
		settings_file.close()

func get_setting(_key : String):
	var return_val = null
	if settings_file.open(settings_path + "/settings.json", File.READ) == OK:
		var settings_strig = settings_file.get_as_text()
		var json_settings_parser = JSON.parse(settings_strig)
		var json_settings = {}
		if json_settings_parser.error == OK:
			json_settings = json_settings_parser.result
		if json_settings.has(_key):
			return_val = json_settings[_key]
			if return_val is String:
				return_val = str2var(return_val)
		settings_file.close()
	return return_val

func get_all_settings():
	if settings_file.open(settings_path + "/settings.json", File.READ) == OK:
		var settings_strig = settings_file.get_as_text()
		var json_settings = JSON.parse(settings_strig)
		if json_settings.error == OK:
			return json_settings.result
	return {}
