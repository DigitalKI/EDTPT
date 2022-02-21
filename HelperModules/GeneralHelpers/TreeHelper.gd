extends Object
class_name TreeHelper

# Searches for a field of a specific table.
# This might not be the ideal way of doing this.
# I haven't fully understood how get_next and get_children work.
# TODO: review if it does some extra loop or if it can be improved.
static func get_event_field_item_by_text(_tree : Tree, _tablename : String, _text : String) -> TreeItem:
	var root_evt_item = _tree.get_root()
#	print("----start----")
	if root_evt_item:
		var table : TreeItem = root_evt_item.get_children()
		while table:
			if table.get_text(0) != _tablename:
				table = table.get_next()
			else:
				var cur : TreeItem = table.get_children()
				while cur:
					var cur_text := cur.get_text(0)
#					print(cur_text)
					if cur_text == _text:
#						print("----end----")
						return cur
					elif cur.get_children():
						cur = cur.get_children()
					else:
						cur = cur.get_next()
#	print("----end----")
	return null

static func get_selected_column_title(_tree : Tree) -> String:
	var result_item := _tree.get_selected()
	var col_idx := _tree.get_selected_column()
	var result_field : String = _tree.get_column_title(col_idx)
	return result_field

static func get_selected_text(_tree : Tree) -> String:
	var result_item := _tree.get_selected()
	var col_idx := _tree.get_selected_column()
	var result_text : String = result_item.get_text(col_idx)
	return result_text

static func get_selected_row_text(_tree : Tree) -> Array:
	var result_array : Array = []
	var result_item := _tree.get_selected()
	for col_idx in _tree.columns:
		result_array.append(result_item.get_text(col_idx))
	return result_array
	
static func cell_to_clipboard(_event : InputEvent, _tree_control : Tree, _metadata : String = ""):
	if _event is InputEventKey:
		if _event.scancode ==  KEY_C && _event.control:
			if _tree_control.get_selected():
				var clipboard_data : String = ""
				if _metadata:
					var current_metadata : Dictionary = _tree_control.get_selected().get_meta(_metadata)
					clipboard_data = DataConverter.dictionary_pretty_print(current_metadata)
				else:
					clipboard_data =_tree_control.get_selected().get_text(_tree_control.get_selected_column())
				OS.clipboard = clipboard_data
	
static func get_selected_meta(_tree_control : Tree, _metadata : String = ""):
	var current_metadata : Dictionary = {}
	if _tree_control.get_selected():
		var clipboard_data : String = ""
		if _metadata:
			current_metadata = _tree_control.get_selected().get_meta(_metadata)
	return current_metadata

static func var_to_table(_tree : Tree, _field : String, _data):
	_tree.clear()
	_tree.columns = 2
	var tree_root : TreeItem = _tree.create_item()
	tree_root.set_meta("address", [_field])
	tree_root.set_tooltip(0, String([_field]))
	if _data is Array:
		handle_array(_tree, _field, _data, tree_root)
	elif _data is Dictionary:
		handle_dictionary(_tree, _data, tree_root)

static func handle_array(_tree : Tree, _rowname : String, _rows : Array, _parent : TreeItem, _depth : int = 0):
	var depth_color : Color = Color(1,1,1).linear_interpolate(Color(0,0,0), float(_depth) / 3.0)
	for row in _rows:
		var new_addr : Array = _parent.get_meta("address").duplicate(true)
		var datarow : TreeItem = _tree.create_item(_parent)
		datarow.set_meta("address", new_addr)
		datarow.set_tooltip(0, String(new_addr))
		if row is String && (row.begins_with("[") || row.begins_with("{")):
			row = parse_json(row)
		if row is Dictionary:
			if _depth == 0:
				datarow.set_text(0, _rowname)
				datarow.set_expand_right(0, true)
				datarow.set_text_align(0, TreeItem.ALIGN_CENTER)
				datarow.set_custom_color(0, depth_color.inverted())
				datarow.set_custom_bg_color(0, depth_color)
				handle_dictionary(_tree, row, datarow, _depth + 1)
			else:
				datarow.free()
				handle_dictionary(_tree, row, _parent, _depth + 1)
		else:
			datarow.set_text(0, _rowname)
			datarow.set_text(1, String(row))

static func handle_dictionary(_tree : Tree, _dict : Dictionary, _parent : TreeItem, _depth : int = 0):
	var depth_color : Color = Color(1,1,1).linear_interpolate(Color(0,0,0), float(_depth) / 3.0)
	for col in _dict.keys():
		var new_addr : Array = _parent.get_meta("address").duplicate(true)
		new_addr.append(col)
		var datarow : TreeItem = _tree.create_item(_parent)
		datarow.set_meta("address", new_addr)
		datarow.set_tooltip(0, String(new_addr))
		if _dict[col] is String && (_dict[col].begins_with("[") || _dict[col].begins_with("{")):
			_dict[col] = parse_json(_dict[col])
			
		if !(_dict[col] is Dictionary || _dict[col] is Array):
			datarow.set_text(0, col)
			datarow.set_text(1, DataConverter.get_value(_dict[col]))
		else:
			datarow.set_text(0, col)
			datarow.set_expand_right(0, true)
			datarow.set_text_align(0, TreeItem.ALIGN_CENTER)
			datarow.set_custom_color(0, depth_color.inverted())
			datarow.set_custom_bg_color(0, depth_color)
			if _dict[col] is Dictionary:
				handle_dictionary(_tree, _dict[col], datarow, _depth + 1)
			elif _dict[col] is Array:
				handle_array(_tree, col, _dict[col], datarow, _depth + 1)
