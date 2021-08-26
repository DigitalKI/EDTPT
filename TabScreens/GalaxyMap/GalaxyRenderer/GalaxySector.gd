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

# This function spawns stars in a sector giving each a certain color and size
# sector is entered manually, it does not check on actual stars positions
# Parameters expected values:
#	_colors = { "federation": Color(1.0, 0.0, 0.0)
#				, "empire": Color(0.0, 1.0, 0.0)
#				, "indipendent": Color(0.0, 0.0, 1.0)}
#	_colors = { "min": Color(1.0, 0.0, 0.0)
#				, "max": Color(0.0, 1.0, 0.0)}
#	_scales = {
#			  "min": the min value expected from _stars data
#			, "max": the max value expected from _stars data
#			, "min_scale": the min scale of the star system represented
#			, "max_scale": the max scale of the star system represented}
#	_colors_addr, _scale_addr: see function get_value_from_dict_address below
func spawn_stars(_stars : Array, _colors_addr: Array, _colors : Dictionary, _scale_addr: Array, _scales: Dictionary):
	$StarsAclose.multimesh.instance_count = _stars.size()
	$StarsAclose.multimesh.visible_instance_count = _stars.size()
	for idx in _stars.size():
		var sys_coord = get_position_vector(_stars[idx]["StarPos"])
		var color_value = get_value_from_dict_address(_colors_addr, _stars[idx])
		var star_color : Color = _colors[String(color_value)]
		var scale_value = get_value_from_dict_address(_scale_addr, _stars[idx])
		var scale_normalized = inverse_lerp(_scales["min"], _scales["max"], scale_value)
		var scale = Vector3(_scales["min_scale"],_scales["min_scale"],_scales["min_scale"]).linear_interpolate(Vector3(_scales["max_scale"], _scales["max_scale"], _scales["max_scale"]), scale_normalized)
		var star_size : Basis = Basis().scaled(scale)
		$StarsAclose.multimesh.set_instance_transform(idx, Transform(star_size, sys_coord))
		$StarsAclose.multimesh.set_instance_color(idx, star_color)
#		print("adding system %s with scale %s" % [_stars[idx]["StarSystem"], scale.length()])

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
	for add in _address:
		value = value[add]
	return value
