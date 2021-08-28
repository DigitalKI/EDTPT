extends Object
class_name DataConverter

static func get_position_vector(_data):
	var position := Vector3()
	var _converted_data = null
	var json_data = JSON.parse(_data)
	if  json_data.error == OK:
		_converted_data = json_data.result
	if _converted_data is Dictionary && _converted_data.size() == 3:
			position.x = _converted_data["x"]
			position.y = _converted_data["y"]
			position.z = _converted_data["z"]
	if _converted_data is Array && _converted_data.size() == 3:
			position.x = _converted_data[0]
			position.y = _converted_data[1]
			position.z = _converted_data[2]
	return position
