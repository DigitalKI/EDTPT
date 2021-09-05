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
		var json_settings = JSON.parse(settings_strig)
		if json_settings.error == OK:
			json_settings.result[_key] = _value
			settings_strig = JSON.print(json_settings.result, "  ", true)
			settings_file.store_string(settings_strig)
		settings_file.close()

func get_setting(_key : String):
	var return_val = null
	if settings_file.open(settings_path + "/settings.json", File.READ) == OK:
		var settings_strig = settings_file.get_as_text()
		var json_settings = JSON.parse(settings_strig)
		if json_settings.error == OK:
			if json_settings.result.has(_key):
				return_val = json_settings.result[_key]
	return return_val

func get_all_settings():
	if settings_file.open(settings_path + "/settings.json", File.READ) == OK:
		var settings_strig = settings_file.get_as_text()
		var json_settings = JSON.parse(settings_strig)
		if json_settings.error == OK:
			return json_settings.result
		else:
			return {}
