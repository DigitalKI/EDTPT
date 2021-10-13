extends Object
class_name DataConverter

static func get_position_vector(_data) -> Vector3:
	var position := Vector3()
	var _converted_data = null
	if _data is String:
		var json_data = JSON.parse(_data)
		if  json_data.error == OK:
			_converted_data = json_data.result
	elif _data is Dictionary:
		_converted_data = _data
	elif _data is Array:
		_converted_data = _data
		
	if _converted_data is Dictionary && _converted_data.size() == 3:
			position.x = -_converted_data["x"]
			position.y = _converted_data["y"]
			position.z = _converted_data["z"]
	elif _converted_data is Array && _converted_data.size() == 3:
			position.x = -_converted_data[0]
			position.y = _converted_data[1]
			position.z = _converted_data[2]
	return position

# this function gets a string value even when data is null
static func get_value(_value):
	var string_value = "null" if (_value == null) else String(_value)
	return string_value

static func dictionary_pretty_print(_data : Dictionary) -> String:
	var clipboard_data : String = ""
	# for each key we try to format data nicely
	# JSON.print does prettyfy arrays and dictionaries
	for val in _data.keys():
		if _data[val] is String:
			var json_data : JSONParseResult = JSON.parse(_data[val])
			if json_data.error == OK && (_data[val].begins_with("[") || _data[val].begins_with("{")):
				clipboard_data += "\n%s:" % val
				clipboard_data += "\n" + JSON.print(json_data.result, "    ")
			else:
				clipboard_data += "\n%s: %s" %[val, _data[val]]
	return clipboard_data.trim_prefix("\n").replace(" | ", "\n")
