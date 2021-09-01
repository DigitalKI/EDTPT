extends MeshInstance
class_name GalaxyPlotter


var arraymesh : ArrayMesh

# Called when the node enters the scene tree for the first time.
func draw_path(_stars : Array, _pos_name : String):
	var points_arr := []
	var color_arr := PoolColorArray()
	var oldest_col := Color(0.1,0.1,0.1)
	var newest_col := Color(1.0,1.0,1.0)
	var counter := 0
	for star in _stars:
		counter += 1
		var starpos = DataConverter.get_position_vector(star[_pos_name])
		var starcol = oldest_col if counter < _stars.size() - 20 else newest_col
		points_arr.append(starpos)
		color_arr.append(starcol)
	arraymesh = ArrayMesh.new()
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = points_arr
	arr[Mesh.ARRAY_COLOR] = color_arr
	arraymesh.add_surface_from_arrays(ArrayMesh.PRIMITIVE_LINE_STRIP, arr)
	mesh = arraymesh

func clear_path():
	for i in arraymesh.get_surface_count():
		arraymesh.surface_remove(i)
