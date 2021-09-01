tool
extends Panel
class_name FloatingTable

onready var title : Label = $MarginContainer/Panel/VBoxContainer/Title
onready var table : Tree = $MarginContainer/Panel/VBoxContainer/DetailsMargin/Table

export(String) var title_text setget _set_title, _get_title
export(Array) var table_array setget _set_table, _get_table
export(Array, String) var visible_columns

signal item_selected(tree_item)
signal item_doubleclicked(tree_item)

func _set_title(_value):
	if is_inside_tree() && _value is String && title:
		title.text = _value

func _get_title():
	if is_inside_tree() && title:
		return title.text
	else:
		return ""

func _set_table(_value):
	if is_inside_tree() && _value is Array && table:
		table_array = _value
		table.clear()
		add_events(_value)

func _get_table():
	return table_array


func _on_Title_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			OS.clipboard = $MarginContainer/Panel/VBoxContainer/Title.text

# Adds an event to the list using the event object
# evey new event is put at the beginning of the tree
func add_events(_data : Array):
	var tree_root : TreeItem = table.create_item()
	table.set_column_titles_visible(true)
	if _data:
		var col_idx = 2
		for _col in _data[0].keys():
			if visible_columns.has(_col) && !["timestamp", "event"].has(_col):
				table.set_column_title(col_idx, _col)
				table.set_column_expand(col_idx, true)
				table.set_column_min_width(col_idx, 110.0)
				col_idx += 1
		table.columns = col_idx
		table.set_column_title(0, "Date")
		table.set_column_expand(0, false)
		table.set_column_min_width(0, 140.0)
		table.set_column_title(1, "Event")
		table.set_column_expand(1, false)
		table.set_column_min_width(1, 150.0)
	
	for log_obj in _data:
		if log_obj is Dictionary:
			var evt : TreeItem = table.create_item(tree_root)
			evt.set_meta("log_object", log_obj)
#			evt.move_to_top() # enabling this will invert order
			var col_idx = 2
			evt.set_text(0, DateTime.format_timestamp(log_obj["timestamp"]))
			evt.set_tooltip(0, log_obj["timestamp"])
			evt.set_text(1, DateTime.format_timestamp(log_obj["event"]))
			for _col in log_obj.keys():
				if !["timestamp", "event"].has(_col) && visible_columns.has(_col):
					evt.set_text(col_idx, String(log_obj[_col] if log_obj[_col] else "NULL"))
					col_idx += 1
			table.columns = col_idx

func _on_Table_item_selected():
	var selected_item = table.get_selected().get_meta("log_object")
	emit_signal("item_selected", selected_item)

func _on_Table_item_activated():
	var selected_item = table.get_selected().get_meta("log_object")
	emit_signal("item_doubleclicked", selected_item)
