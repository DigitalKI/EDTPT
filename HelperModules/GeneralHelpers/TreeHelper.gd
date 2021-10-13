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
