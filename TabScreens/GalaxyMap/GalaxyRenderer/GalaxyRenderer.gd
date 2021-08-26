extends Spatial


func _ready():
	get_near_quadrants(Vector3(200.8,101.58, 10.054), 200, 10)

func get_near_quadrants(_pos : Vector3, _quadrant_size : float, _treshold : float):
	var quadrant = (_pos / _quadrant_size).floor()
	var unit_pos = _pos - _pos.round()
	print("Current quadrant is %s" % [quadrant])
	print("Nearest quadrant is at %s" % [unit_pos])
	pass
