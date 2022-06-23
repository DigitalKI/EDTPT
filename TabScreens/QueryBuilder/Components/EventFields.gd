extends Tabs
class_name EventFields

export(Color) var selected_field_bg : Color = Color("#d5d5d5")
export(Color) var selected_field_fg : Color = Color("#3a3a3a")

onready var events_fields : Tree = $PanelResult/EventFields
onready var events_fields_popup : PopupMenu = $PanelResult/EventFields/PopupRemoveTable

var tree_root : TreeItem
var query_structure : Dictionary

signal query_changed(sql_query)
signal clear_all

func _on_EventFields_item_activated():
	var sql_query : String = ""
	var selected_item : TreeItem = events_fields.get_selected()
	if selected_item.get_children():
		selected_item.collapsed = !selected_item.collapsed
	elif update_query_structure(selected_item) == "added":
		selected_item.set_custom_bg_color(0, selected_field_bg)
		selected_item.set_custom_color(0, selected_field_fg)
		selected_item.set_custom_bg_color(1, selected_field_bg)
		selected_item.set_custom_color(1, selected_field_fg)
		selected_item.set_custom_bg_color(2, selected_field_bg)
		selected_item.set_custom_color(2, selected_field_fg)
		selected_item.set_custom_bg_color(3, selected_field_bg)
		selected_item.set_custom_color(3, selected_field_fg)
	else:
		selected_item.set_custom_bg_color(0, selected_field_fg)
		selected_item.set_custom_color(0, selected_field_bg)
		selected_item.set_custom_bg_color(1, selected_field_fg)
		selected_item.set_custom_color(1, selected_field_bg)
		selected_item.set_custom_bg_color(2, selected_field_bg)
		selected_item.set_custom_color(2, selected_field_fg)
		selected_item.set_custom_bg_color(3, selected_field_bg)
		selected_item.set_custom_color(3, selected_field_fg)
		selected_item.set_text(1, "")
	sql_query = data_reader.query_builder.query_structure_to_select(query_structure["structure"])
	emit_signal("query_changed", sql_query)
	return sql_query

func _on_EventFields_item_selected():
	# You can delete the code below.
	var selected = events_fields.get_selected()
	var l_checked = selected.is_checked(1)
	var d_checked = selected.is_checked(2)
	if l_checked || d_checked:
		print("hello")
#	events_fields.get_selected().set_editable(1, false)


func _on_EventFields_item_edited():
	var selected = events_fields.get_selected()
	update_query_structure(events_fields.get_selected())
	var sql_query : String = data_reader.query_builder.query_structure_to_select(query_structure["structure"])
	emit_signal("query_changed", sql_query)

func _on_EventFields_gui_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER:
			events_fields.get_selected().set_editable(1, false)
			update_query_structure(events_fields.get_selected())
			var sql_query : String = data_reader.query_builder.query_structure_to_select(query_structure["structure"])
			emit_signal("query_changed", sql_query)

func _on_EventFields_item_rmb_selected(position):
	var selected_item : TreeItem = events_fields.get_item_at_position(position)
	selected_item.select(1)
	events_fields_popup.rect_position = position + Vector2(events_fields_popup.rect_size.x, events_fields_popup.rect_size.y / 2)
	if selected_item.get_children():
		events_fields_popup.set_item_disabled(0, false)
		events_fields_popup.set_item_disabled(2, true)
		events_fields_popup.set_item_disabled(3, true)
	else:
		events_fields_popup.set_item_disabled(0, true)
		events_fields_popup.set_item_disabled(2, false)
		events_fields_popup.set_item_disabled(3, false)
	events_fields_popup.popup()

func _on_PopupRemoveTable_id_pressed(id):
	#id 0 corresponds to remove table
	#id 2 corresponds to add filter
	#id 3 corresponds to add visual rule
	if id == 0:
		remove_event_types(events_fields.get_selected().get_text(0))
	elif id == 2:
		var editing_item : TreeItem = events_fields.get_selected()
		editing_item.set_editable(3, true)
		if events_fields.edit_selected():
			print(editing_item.get_text(0))
	elif id == 3:
		pass

func _on_BtRemoveAll_pressed():
	query_structure["structure"].clear()
	emit_signal("clear_all")

func initialize_event_fields():
	events_fields.clear()
	events_fields.set_column_titles_visible(true)
	events_fields.set_column_title(0, "Field")
	events_fields.set_column_min_width(0, 70)
	events_fields.set_column_expand(0, true)
	events_fields.set_column_title(1, "L")
	events_fields.set_column_min_width(1, 10)
	events_fields.set_column_title(2, "D")
	events_fields.set_column_min_width(2, 10)
	events_fields.set_column_title(3, "Filter")
	events_fields.set_column_min_width(3, 30)

func add_event_types(_event_name : String, _event_color : Color):
	# If the event name (table) does not exists, add it.
	# This is to allow automatic save of the selected tables,
	# even if no field is selected.
	if !query_structure["structure"].has(_event_name):
		query_structure["structure"][_event_name] = {}
	tree_root = events_fields.get_root()
	if !tree_root:
		tree_root = events_fields.create_item()
	elif !(tree_root is TreeItem):
		tree_root = events_fields.create_item()
	var table_item : TreeItem = events_fields.create_item(tree_root)
	table_item.set_text(0, _event_name)
	table_item.set_custom_color(0, Color(0,0,0))
	table_item.set_custom_bg_color(0, _event_color)
	table_item.set_expand_right(0, true)
	table_item.set_text_align(0, TreeItem.ALIGN_CENTER)
	var event_fields = data_reader.dbm.get_table_fields(_event_name)
	for fld in event_fields:
		var type_item : TreeItem = events_fields.create_item(table_item)
		type_item.set_text(0, fld["name"])
		type_item.set_metadata(0, fld["type"])
		type_item.set_tooltip(0, "{name} ({type})".format(fld))
		type_item.set_custom_bg_color(0, selected_field_fg)
		type_item.set_custom_color(0, selected_field_bg)
		type_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		type_item.set_custom_bg_color(1, selected_field_fg)
		type_item.set_custom_color(1, selected_field_bg)
		type_item.set_editable(1, true)
		type_item.set_cell_mode(2, TreeItem.CELL_MODE_CHECK)
		type_item.set_custom_bg_color(2, selected_field_fg)
		type_item.set_custom_color(2, selected_field_bg)
		type_item.set_editable(2, true)
		type_item.set_custom_bg_color(3, selected_field_fg)
		type_item.set_custom_color(3, selected_field_bg)

func remove_event_types(_event_name : String):
	var sql_select : String = ""
	query_structure["structure"].erase(_event_name)
	sql_select = data_reader.query_builder.query_structure_to_select(query_structure["structure"])
	var root_evt_item = events_fields.get_root()
	var cur : TreeItem = root_evt_item.get_children()
	while cur:
		if cur.get_text(0) == _event_name:
			root_evt_item.remove_child(cur)
		cur = cur.get_next()
	emit_signal("query_changed", sql_select)
	events_fields.update()

func get_event_types() -> Array:
	var event_types : Array = []
	var root_evt_item = events_fields.get_root()
	if root_evt_item:
		var cur : TreeItem = root_evt_item.get_children()
		while cur:
			if cur.get_children():
				event_types.append(cur.get_text(0))
			cur = cur.get_next()
	return event_types

func query_structure_to_ui(_event_types_table : EventTypesTable):
	for tablename in query_structure["structure"].keys():
		var selected_event_color := _event_types_table.get_event_type_color_by_text(tablename)
		add_event_types(tablename, selected_event_color)
		for fieldname in query_structure["structure"][tablename].keys():
			var event_field := TreeHelper.get_event_field_item_by_text(events_fields, tablename, fieldname)
			var event_field_settings : Dictionary = query_structure["structure"][tablename][fieldname]
			if event_field:
				if event_field_settings.has("list"):
					event_field.set_checked(1, event_field_settings["list"])
				if event_field_settings.has("detail"):
					event_field.set_checked(2, event_field_settings["detail"])
				if event_field_settings.has("filter"):
					event_field.set_checked(3, event_field_settings["detail"])

# Gets the tree structure and converts it into a dictionary format.
# The dictionary format can then be easily manipulated and saved into a JSON format.
func update_query_structure(_selected_field : TreeItem):
	var result = ""
	for evt_typ in get_event_types():
		if !query_structure["structure"].has(evt_typ):
			query_structure["structure"][evt_typ] = {}
	if _selected_field.get_text(0).length() > 0:
		var event_type_item : TreeItem = _selected_field.get_parent()
		var event_type : String = event_type_item.get_text(0)
		var event_field : String = _selected_field.get_text(0)
		if event_type:
			if query_structure["structure"][event_type].has(event_field) \
			&& (query_structure["structure"][event_type][event_field]["list"] \
			||  query_structure["structure"][event_type][event_field]["detail"]):
				query_structure["structure"][event_type].erase(event_field)
				result = "removed"
			else:
				query_structure["structure"][event_type][event_field] = {}
				query_structure["structure"][event_type][event_field]["list"] = _selected_field.is_checked(1)
				query_structure["structure"][event_type][event_field]["detail"] = _selected_field.is_checked(2)
				query_structure["structure"][event_type][event_field]["filter"] = _selected_field.get_text(3)
					
				result = "added"
#	data_reader.settings_manager.save_setting("query_views", views_data)
	return result

func clear():
	events_fields.clear()



