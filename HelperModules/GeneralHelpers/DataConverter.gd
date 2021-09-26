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
