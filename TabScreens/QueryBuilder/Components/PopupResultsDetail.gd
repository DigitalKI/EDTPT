extends PopupPanel
class_name PopupResultsDetail

onready var table : Tree = $VBoxContainer/DetailTree


func fill_table(_field : String, _data):
	table.clear()
	table.columns = 2
	var tree_root : TreeItem = table.create_item()
	if _data is Array:
		handle_array(_field, _data, tree_root)
	elif _data is Dictionary:
		handle_dictionary(_data, tree_root)

func handle_array(_rowname : String, _rows : Array, _parent : TreeItem, _depth : int = 0):
	var depth_color : Color = Color(1,1,1).linear_interpolate(Color(0,0,0), float(_depth) / 3.0)
	for row in _rows:
		var datarow : TreeItem = table.create_item(_parent)
		if row is Dictionary:
			datarow.set_text(0, _rowname)
			datarow.set_expand_right(0, true)
			datarow.set_text_align(0, TreeItem.ALIGN_CENTER)
			datarow.set_custom_color(0, depth_color.inverted())
			datarow.set_custom_bg_color(0, depth_color)
			handle_dictionary(row, datarow, _depth + 1)
		else:
			datarow.set_text(0, _rowname)
			datarow.set_text(1, String(row))

func handle_dictionary(_dict : Dictionary, _parent : TreeItem, _depth : int = 0):
	var depth_color : Color = Color(1,1,1).linear_interpolate(Color(0,0,0), float(_depth) / 3.0)
	for col in _dict.keys():
		var datarow : TreeItem = table.create_item(_parent)
		if !(_dict[col] is Dictionary || _dict[col] is Array):
			datarow.set_text(0, col)
			datarow.set_text(1, String(_dict[col]))
		elif _dict[col] is Dictionary:
			datarow.set_text(0, col)
			datarow.set_expand_right(0, true)
			datarow.set_text_align(0, TreeItem.ALIGN_CENTER)
			datarow.set_custom_color(0, depth_color.inverted())
			datarow.set_custom_bg_color(0, depth_color)
			handle_dictionary(_dict[col], datarow, _depth + 1)
		elif _dict[col] is Array:
			datarow.free()
			handle_array(col, _dict[col], _parent, _depth + 1)
