extends Object
class_name SettingsManager

var settings_path : String = "user://settings"
var settings_file : File = File.new()

func _init():
	var settings_directory : Directory = Directory.new()
	if !settings_directory.dir_exists(settings_path):
		settings_directory.make_dir(settings_path)

func save_setting(_key : String, _value):
	if settings_file.open(settings_path + "/settings.json", File.READ_WRITE) == OK:
		var settings_strig = settings_file.get_as_text()
		var json_settings_parser = JSON.parse(settings_strig)
		var json_settings = {}
		if json_settings_parser.error == OK:
			json_settings = json_settings_parser.result
		json_settings[_key] = var2str(_value)
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
		else:
			return {}
