extends Control

onready var event_tabs : TabContainer = $HBoxContainer/TabContainer
onready var saved_views : ItemList = $HBoxContainer/TabContainer/SavedViews/SavedViewsList
onready var view_title : LineEdit = $HBoxContainer/TabContainer/EventFields/PanelResult/TbViewTitle
onready var event_types_table : ItemList = $HBoxContainer/TabContainer/EventTypes/EventTypes
onready var events_fields : Tree = $HBoxContainer/TabContainer/EventFields/PanelResult/EventFields
onready var events_fields_popup : PopupMenu = $HBoxContainer/TabContainer/EventFields/PanelResult/EventFields/PopupRemoveTable
onready var query_view: TextEdit = $HBoxContainer/TabContainer/QueryView/ResultingQuery
onready var results_table : Tree = $HBoxContainer/ResultsTable

var tree_root : TreeItem
export(Color) var coords_bg : Color = Color("#ff7802")
export(Color) var coords_fg : Color = Color("#230089")
export(Color) var system_bg : Color = Color("#0033cc")
export(Color) var system_fg : Color = Color("#ff7802")
export(Color) var selected_field_bg : Color = Color("#d5d5d5")
export(Color) var selected_field_fg : Color = Color("#3a3a3a")
var field_bg : Color = Color("#d5d5d5")
var field_fg : Color = Color("#3a3a3a")

var event_tables_coords : Array
var event_tables_system_addr : Array
var query_structure : Dictionary = {}

func _ready():
	event_tables_coords = data_reader.dbm.get_all_event_tables(" AND (sql like '%StarPos%' OR sql LIKE '%coords%')")
	event_tables_system_addr = data_reader.dbm.get_all_event_tables(" AND SQL LIKE '%SystemAddress%'")

func _on_SavedViewsList_item_activated(index):
	if index == 0:
		saved_views.add_item("no title")
		saved_views.select(saved_views.get_item_count() - 1)
		event_tabs.current_tab = 2

func _on_EventTypes_item_activated(index):
	if query_structure.size() < 5:
		var selected_event_type := event_types_table.get_item_text(index)
		var selected_event_color := event_types_table.get_item_custom_bg_color(index)
		if !get_event_types().has(selected_event_type):
			add_events_fields(selected_event_type, selected_event_color)
			event_tabs.tabs_visible = 1

func _on_BtRemoveAll_pressed():
	query_structure.clear()
	events_fields.clear()
	results_table.clear()
	query_view.text = ""

func _on_EventFields_item_activated():
	var selected_item : TreeItem = events_fields.get_selected()
	if selected_item.get_children():
		selected_item.collapsed = !selected_item.collapsed
	elif build_query_structure(selected_item) == "added":
		selected_item.set_custom_bg_color(0, selected_field_bg)
		selected_item.set_custom_color(0, selected_field_fg)
		selected_item.set_custom_bg_color(1, selected_field_bg)
		selected_item.set_custom_color(1, selected_field_fg)
	else:
		selected_item.set_custom_bg_color(0, selected_field_fg)
		selected_item.set_custom_color(0, selected_field_bg)
		selected_item.set_custom_bg_color(1, selected_field_fg)
		selected_item.set_custom_color(1, selected_field_bg)
		selected_item.set_text(1, "")
	query_view.text = query_structure_to_select()
	get_result_table(query_view.text + " LIMIT 1000")

func _on_EventFields_item_selected():
	events_fields.get_selected().set_editable(1, false)

func _on_EventFields_gui_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER:
			events_fields.get_selected().set_editable(1, false)
			build_query_structure(events_fields.get_selected())
			query_view.text = query_structure_to_select()
			get_result_table(query_view.text + " LIMIT 1000")

func _on_EventFields_item_rmb_selected(position):
	var selected_item : TreeItem = events_fields.get_item_at_position(position)
	selected_item.select(1)
	events_fields_popup.rect_position = position + events_fields_popup.rect_size
	if selected_item.get_children():
		events_fields_popup.set_item_disabled(0, false)
		events_fields_popup.set_item_disabled(2, true)
	else:
		events_fields_popup.set_item_disabled(0, true)
		events_fields_popup.set_item_disabled(2, false)
	events_fields_popup.popup()

func _on_PopupRemoveTable_id_pressed(id):
	if id == 0:
		remove_event_fields(events_fields.get_selected().get_text(0))
	elif id == 2:
		var editing_item : TreeItem = events_fields.get_selected()
		editing_item.set_editable(1, true)
		if events_fields.edit_selected():
			print(editing_item.get_text(0))
	get_result_table(query_view.text + " LIMIT 1000")

func _on_BtApplySql_pressed():
	pass # Replace with function body.

func build_query_structure(_selected_field : TreeItem):
	var result = ""
	for evt_typ in get_event_types():
		if !query_structure.has(evt_typ):
			query_structure[evt_typ] = {}
	if _selected_field.get_text(0).length() > 0:
		var event_type_item : TreeItem = _selected_field.get_parent()
		if event_type_item.get_text(0):
			if !query_structure.has(event_type_item.get_text(0)):
				query_structure[event_type_item.get_text(0)] = {}
			if query_structure[event_type_item.get_text(0)].has(_selected_field.get_text(0)):
				query_structure[event_type_item.get_text(0)].erase(_selected_field.get_text(0))
				result = "removed"
			else:
				query_structure[event_type_item.get_text(0)][_selected_field.get_text(0)] = ""
				if _selected_field.get_text(1):
					query_structure[event_type_item.get_text(0)][_selected_field.get_text(0)] = _selected_field.get_text(1)
				result = "added"
	return result

func query_structure_to_select():
	var resulting_query : String = "SELECT"
	var tables_query := "\n FROM "
	var fields_query := ""
	var filters_query := "\n WHERE 1=1 "
	var prev_tbl := ""
	for tbl in query_structure.keys():
		var has_sys_addr : bool = event_tables_coords.has(tbl) || event_tables_system_addr.has(tbl)
		for fld in query_structure[tbl].keys():
			fields_query += ", %s.%s" % [tbl, fld]
			if query_structure[tbl][fld]:
				filters_query += " AND %s %s" % [fld, query_structure[tbl][fld]]
		tables_query += " INNER JOIN {tbl} ON {prev_tbl}.SystemAddress = {tbl}.SystemAddress".format({"prev_tbl": prev_tbl, "tbl": tbl}) if has_sys_addr && prev_tbl.length() > 0 else tbl
		prev_tbl = tbl
	resulting_query += fields_query.trim_prefix(",") + tables_query + filters_query
	return resulting_query

func initialize_builder():
	list_all_tables()
	initialize_event_fields()

func list_all_tables():
	event_types_table.clear()
	var event_tables = data_reader.dbm.get_all_event_tables()
	for sys_tbl in event_tables_coords:
		event_types_table.add_item(sys_tbl)
		event_types_table.set_item_custom_bg_color(event_types_table.get_item_count() - 1, coords_bg)
		event_types_table.set_item_custom_fg_color(event_types_table.get_item_count() - 1, coords_fg)
	for addr_tbl in event_tables_system_addr:
		if !event_tables_coords.has(addr_tbl):
			event_types_table.add_item(addr_tbl)
			event_types_table.set_item_custom_bg_color(event_types_table.get_item_count() - 1, system_bg)
			event_types_table.set_item_custom_fg_color(event_types_table.get_item_count() - 1, system_fg)
	for tbl in event_tables:
		if !event_tables_coords.has(tbl) && !event_tables_system_addr.has(tbl):
			event_types_table.add_item(tbl)

func initialize_event_fields():
	query_structure.clear()
	events_fields.clear()
	events_fields.set_column_titles_visible(true)
	events_fields.set_column_title(0, "Field")
	events_fields.set_column_min_width(0, 70)
	events_fields.set_column_expand(0, true)
	events_fields.set_column_title(1, "Filter")
	events_fields.set_column_min_width(1, 30)

func add_events_fields(_event_name : String, _event_color : Color):
	if !tree_root is TreeItem:
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
		type_item.set_custom_bg_color(1, selected_field_fg)
		type_item.set_custom_color(1, selected_field_bg)

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

func remove_event_fields(_event_name : String):
	query_structure.erase(_event_name)
	query_view.text = query_structure_to_select()
	var root_evt_item = events_fields.get_root()
	var cur : TreeItem = root_evt_item.get_children()
	while cur:
		if cur.get_text(0) == _event_name:
			root_evt_item.remove_child(cur)
		cur = cur.get_next()

func get_result_table(_events_query : String):
	var events := data_reader.dbm.db_execute_select(_events_query)
	results_table.clear()
	results_table.set_column_titles_visible(true)
	if !events.empty():
		results_table.columns = events[0].size()
		for col_idx in  events[0].size():
			results_table.set_column_title(col_idx, events[0].keys()[col_idx])
	var results_table_root : TreeItem = results_table.create_item()
	for evt in events:
		var type_item : TreeItem = results_table.create_item(results_table_root)
		var col_idx = 0
		for col in evt.keys():
			type_item.set_text(col_idx, "" if !evt[col] else String(evt[col]))
			col_idx += 1

