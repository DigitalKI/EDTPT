extends PopupPanel
class_name PopupResultsDetail

onready var table : Tree = $VBoxContainer/DetailTree
signal field_selected(addr)

var current_field : String = ""

func fill_table(_field : String, _data):
	current_field = _field
	table.clear()
	table.columns = 2
	var tree_root : TreeItem = table.create_item()
	tree_root.set_meta("addr", [_field])
	tree_root.set_tooltip(0, String([_field]))
	if _data is Array:
		handle_array(_field, _data, tree_root)
	elif _data is Dictionary:
		handle_dictionary(_data, tree_root)

func handle_array(_rowname : String, _rows : Array, _parent : TreeItem, _depth : int = 0):
	var depth_color : Color = Color(1,1,1).linear_interpolate(Color(0,0,0), float(_depth) / 3.0)
	for row in _rows:
		var new_addr : Array = _parent.get_meta("addr").duplicate(true)
		var datarow : TreeItem = table.create_item(_parent)
		datarow.set_meta("addr", new_addr)
		datarow.set_tooltip(0, String(new_addr))
		if row is Dictionary:
			if _depth == 0:
				datarow.set_text(0, _rowname)
				datarow.set_expand_right(0, true)
				datarow.set_text_align(0, TreeItem.ALIGN_CENTER)
				datarow.set_custom_color(0, depth_color.inverted())
				datarow.set_custom_bg_color(0, depth_color)
				handle_dictionary(row, datarow, _depth + 1)
			else:
				datarow.free()
				handle_dictionary(row, _parent, _depth + 1)
		else:
			datarow.set_text(0, _rowname)
			datarow.set_text(1, String(row))

func handle_dictionary(_dict : Dictionary, _parent : TreeItem, _depth : int = 0):
	var depth_color : Color = Color(1,1,1).linear_interpolate(Color(0,0,0), float(_depth) / 3.0)
	for col in _dict.keys():
		var new_addr : Array = _parent.get_meta("addr").duplicate(true)
		new_addr.append(col)
		var datarow : TreeItem = table.create_item(_parent)
		datarow.set_meta("addr", new_addr)
		datarow.set_tooltip(0, String(new_addr))
		if !(_dict[col] is Dictionary || _dict[col] is Array):
			datarow.set_text(0, col)
			datarow.set_text(1, String(_dict[col]))
		else:
			datarow.set_text(0, col)
			datarow.set_expand_right(0, true)
			datarow.set_text_align(0, TreeItem.ALIGN_CENTER)
			datarow.set_custom_color(0, depth_color.inverted())
			datarow.set_custom_bg_color(0, depth_color)
			if _dict[col] is Dictionary:
				handle_dictionary(_dict[col], datarow, _depth + 1)
			elif _dict[col] is Array:
				handle_array(col, _dict[col], datarow, _depth + 1)

func _on_DetailTree_item_activated():
	var selected_column : String = TreeHelper.get_selected_column_title(table)
	var selected_fields : Array = TreeHelper.get_selected_row_text(table)
	var selected_cell : String = TreeHelper.get_selected_text(table)
	emit_signal("field_selected", table.get_selected().get_meta("addr"))
	visible = false
