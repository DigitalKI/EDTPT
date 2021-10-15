tool
extends Spatial
class_name GalaxySector

export(float) var sector_size = 200.0
export(Vector3) var sector setget _set_sector, _get_sector
var star_aclose_mesh = preload("res://TabScreens/GalaxyMap/GalaxyRes/GalaxyStar.tres")

func _set_sector(_value : Vector3):
	translation = _value.round() * sector_size

func _get_sector():
	return translation / sector_size

func _ready():
	$StarsAclose.multimesh = MultiMesh.new()
	$StarsAclose.multimesh.color_format = MultiMesh.COLOR_FLOAT
	$StarsAclose.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	$StarsAclose.multimesh.mesh = star_aclose_mesh

func get_multimesh():
	return $StarsAclose.multimesh


func get_sample_config():
	var _config = [
	# This gives a specific color based on a lisf of possible values
	{"address": ["factions"]
	, "color_matrix": {"Empire": Color(1.0,0.0,0.0)
					, "Federation": Color(0.0,0.0,1.0)
					, "Alliance": Color(0.0,1.0,0.0)}
	, "is_array": false}
	# This gives a specific color based on a lisf of possible values
	# since is_array, it interpolate the multiple colors associated with the values
	# ie. a planet with metallic and icy will interpolate red with green
	,{"address": ["Rings", "RingClass"]
	, "color_matrix":{"eRingClass_Metalic": Color(1.0,0.0,0.0)
					, "eRingClass_MetalRich": Color(0.0,0.0,1.0)
					, "eRingClass_Rocky": Color(1.0,1.0,0.0)
					, "eRingClass_Icy": Color(0.0,1.0,0.0)}
	, "is_array": true}
	#this gives a size based on a scale
	,{"address": ["RingsAmount"]
	, "size_scales":{"min": 0, "max": 15, "min_scale": 0.5, "max_scale": 4}
	, "is_array": false}
	#this blends color based on a scale
	,{"address": ["RingsAmount"]
	, "color_scales":{"min": 0, "max": 15, "min_scale": Color(1.0,0.0,0.0), "max_scale": Color(0.0,0.0,1.0)}
	, "is_array": false}]

# This function spawns stars in a sector giving each a certain color and size
# sector is entered manually, it does not check on actual stars positions
# Parameters description:
#	_stars			Is the array of data passed containing info for each star, it always have to contain a position coordinate
#	_config			Is an array of dictionaries that is better explained in the examples above (get_sample_config)
#	_default_color	If never assigned, the star takes this color
#	_default_size	If never assigned, the star takes this size
func spawn_stars(_stars : Array, _config : Array, _default_color = Color(0.5, 0.5, 0.5), _default_size = 1.0):
	$StarsAclose.multimesh.instance_count = _stars.size()
	$StarsAclose.multimesh.visible_instance_count = _stars.size()
	for idx in _stars.size():
		_config_star(_stars[idx], idx, _config, _default_color, _default_size)
#		print("adding system %s with scale %s" % [_stars[idx]["StarSystem"], scale.length()])

func add_star(_star : Dictionary, _config : Array, _default_color = Color(0.5, 0.5, 0.5), _default_size = 1.0):
	$StarsAclose.multimesh.instance_count += 1
	$StarsAclose.multimesh.visible_instance_count += 1
	_config_star(_star, $StarsAclose.multimesh.instance_count - 1, _config, _default_color, _default_size)

func _config_star(_star : Dictionary, _star_idx : int, _config : Array, _default_color : Color, _default_size : float):
	var final_color : Color = _default_color
	var star_size : Basis = Basis().scaled(Vector3(_default_size, _default_size, _default_size))
	var color_unassigned = true
	var sys_coord : Vector3 = DataConverter.get_position_vector(_star["StarPos"])
	for _c in _config:
		if _c.has("color_matrix"):
			if _c["is_array"]:
				var arr_values = get_value_from_dict_address(_c["address"], _star)
				for _cval in arr_values:
					if _c["color_matrix"].has(_cval):
						if color_unassigned:
							final_color = _c["color_matrix"][_cval]
							color_unassigned = false
						else:
							final_color = final_color.linear_interpolate(_c["color_matrix"][_cval], 0.5)
			else:
				var colval = get_value_from_dict_address(_c["address"], _star)
				if colval is Array:
					for val in colval:
						if _c["color_matrix"].has(val):
							if color_unassigned:
								final_color = _c["color_matrix"][val]
								color_unassigned = false
				elif _c["color_matrix"].has(colval):
					if color_unassigned:
						final_color = _c["color_matrix"][colval]
						color_unassigned = false
					else:
						final_color = final_color.linear_interpolate(_c["color_matrix"][colval], 0.5)
		elif _c.has("color_scales"):
			var color_value = get_value_from_dict_address(_c["address"], _star)
			if color_value is float || color_value is int:
				color_value = [color_value]
				final_color = _c["color_scales"]["min_scale"]
			if color_value == null:
				color_value = []
			for cval in color_value:
				if cval > _c["color_scales"]["min"] && cval < _c["color_scales"]["max"]:
					var color_normalized = inverse_lerp(_c["color_scales"]["min"], _c["color_scales"]["max"], cval)
					final_color = final_color.linear_interpolate(_c["color_scales"]["max_scale"], color_normalized)
		elif _c.has("size_scales"):
			var scale_value = get_value_from_dict_address(_c["address"], _star)
			if !(scale_value is float || scale_value is int):
				scale_value = _c["size_scales"]["min"]
			var scale_normalized = inverse_lerp(_c["size_scales"]["min"], _c["size_scales"]["max"], scale_value)
			if scale_normalized > 1.0:
				print("scale is too high! %s" % scale_normalized)
				scale_normalized = 1.0
			var scale = Vector3(_c["size_scales"]["min_scale"],_c["size_scales"]["min_scale"],_c["size_scales"]["min_scale"]).linear_interpolate(Vector3(_c["size_scales"]["max_scale"], _c["size_scales"]["max_scale"], _c["size_scales"]["max_scale"]), scale_normalized)
			star_size = Basis().scaled(scale)
	$StarsAclose.multimesh.set_instance_transform(_star_idx, Transform(star_size, sys_coord))
	$StarsAclose.multimesh.set_instance_color(_star_idx, final_color)

func get_star_position_by_id(_id : int) -> Vector3:
	return $StarsAclose.multimesh.get_instance_transform(_id).origin

func get_position_vector(_position_data):
	var position = Vector3()
	if _position_data is String:
		var json_pos = parse_json(_position_data)
		if json_pos is Array:
			position = Vector3(json_pos[0], json_pos[1], json_pos[2])
		if json_pos is Dictionary:
			position = Vector3(json_pos["x"], json_pos["y"], json_pos["x"])
	return position

# Given an array we find the value that corresponds to that "address"
# each element of the array goes deep 1 level of the Dictionary
# For example, given the following paraneters:
#		_address = ["information", "allegiance"]
#		_dict = {"information": {"allegiance": "empire", "population":1000000}
# we get the value "empire" from _dict
func get_value_from_dict_address(_address : Array, _dict : Dictionary):
	var value = _dict
	for addr in _address:
		value = get_value_from_key(addr, value)
	return DataConverter.parse_var(value)

func get_value_from_key(_key : String, _data):
	if _data is String:
		if _data.begins_with("{") || _data.begins_with("["):
			_data = parse_json(_data)
	if _data is Dictionary:
		if _data.has(_key):
			_data = _data[_key]
		else:
			_data = null
	elif _data is Array:
		var temp_values : Array = []
		for val in _data:
			if val is Dictionary:
				var inn_val = get_value_from_key(_key, val)
				if inn_val:
					temp_values.append(inn_val)
			elif val == _key:
				temp_values.append(val)
		if temp_values.empty():
			_data = null
		else:
			_data = temp_values
	else:
		_data = null
	return _data
