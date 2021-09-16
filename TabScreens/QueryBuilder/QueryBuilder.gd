extends Control

onready var event_tabs : TabContainer = $HBoxContainer/TabContainer
onready var event_types_table : ItemList = $HBoxContainer/TabContainer/EventTypes/EventTypes
onready var events_fields : Tree = $HBoxContainer/TabContainer/EventFields/EventFields
onready var query_view: TextEdit = $HBoxContainer/TabContainer/QueryView/ResultingQuery
onready var selected_events : ItemList = $HBoxContainer/PanelResult/SelectedEvents

var tree_root : TreeItem
export(Color) var coords_bg : Color = Color("#ff7802")
export(Color) var coords_fg : Color = Color("#230089")
export(Color) var system_bg : Color = Color("#0033cc")
export(Color) var system_fg : Color = Color("#ff7802")
export(Color) var selected_field_bg : Color = Color("#d5d5d5")
export(Color) var selected_field_fg : Color = Color("#3a3a3a")
var field_bg : Color = Color("#d5d5d5")
var field_fg : Color = Color("#3a3a3a")

var query_structure : Dictionary = {}

func _ready():
	pass

func _on_EventTypes_item_activated(index):
	if selected_events.get_item_count() < 10:
		var selected_event_type := event_types_table.get_item_text(index)
		var selected_event_color := event_types_table.get_item_custom_bg_color(index)
		selected_events.add_item(selected_event_type)
		selected_events.set_item_custom_bg_color(selected_events.get_item_count() - 1, selected_event_color)
		show_events_fields(selected_event_type)
		event_tabs.tabs_visible = 1

func _on_BtRemoveAll_pressed():
	selected_events.clear()
	query_structure.clear()

func _on_EventFields_item_activated():
	var selected_item : TreeItem = events_fields.get_selected()
	if selected_item.get_children():
		selected_item.collapsed = !selected_item.collapsed
	elif build_query_structure(selected_item) == "added":
		selected_item.set_custom_bg_color(0, selected_field_bg)
		selected_item.set_custom_color(0, selected_field_fg)
	else:
		selected_item.set_custom_bg_color(0, selected_field_fg)
		selected_item.set_custom_color(0, selected_field_bg)
	query_view.text = query_structure_to_select()

func build_query_structure(_selected_field : TreeItem):
	var result = ""
	if _selected_field.get_text(0).length() > 0:
		var event_type_item : TreeItem = _selected_field.get_parent()
		if event_type_item.get_text(0):
			if !query_structure.has(event_type_item.get_text(0)):
				query_structure[event_type_item.get_text(0)] = []
			if query_structure[event_type_item.get_text(0)].has(_selected_field.get_text(0)):
				query_structure[event_type_item.get_text(0)].erase(_selected_field.get_text(0))
				result = "removed"
			else:
				query_structure[event_type_item.get_text(0)].append(_selected_field.get_text(0))
				result = "added"
	return result

func query_structure_to_select():
	var resulting_query : String = "SELECT"
	var tables_query := ""
	var fields_query := ""
	for tbl in query_structure.keys():
		for fld in query_structure[tbl]:
			fields_query += ", %s" % fld
		tables_query += ", %s" % tbl
	resulting_query += fields_query.trim_prefix(",") + " FROM " + tables_query.trim_prefix(",")
	return resulting_query

func initialize_builder():
	list_all_tables()
	initialize_event_fields()

func list_all_tables():
	event_types_table.clear()
	selected_events.clear()
	var event_tables = data_reader.dbm.get_all_event_tables()
	var event_tables_coords : Array = data_reader.dbm.get_all_event_tables(" AND (sql like '%StarPos%' OR sql LIKE '%coords%')")
	var event_tables_system_addr : Array = data_reader.dbm.get_all_event_tables(" AND SQL LIKE '%SystemAddress%'")
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
	tree_root = events_fields.create_item()
	events_fields.set_column_titles_visible(true)
	events_fields.set_column_title(0, "Fieldname")
	events_fields.set_column_min_width(0, 100)
	events_fields.set_column_expand(0, true)
	events_fields.set_column_title(1, "Type")
	events_fields.set_column_min_width(1, 40)
	field_bg = tree_root.get_custom_bg_color(0)
	field_fg = tree_root.get_custom_color(0)

func show_events_fields(_event_name : String):
	var table_item : TreeItem = events_fields.create_item(tree_root)
	table_item.set_text(0, _event_name)
	table_item.set_custom_color(0, Color(0,0,0))
	table_item.set_custom_bg_color(0, Color(0,1.0,0))
	table_item.set_expand_right(0, true)
	table_item.set_text_align(0, TreeItem.ALIGN_CENTER)
	var event_fields = data_reader.dbm.get_table_fields(_event_name)
	for fld in event_fields:
		var type_item : TreeItem = events_fields.create_item(table_item)
		type_item.set_text(0, fld["name"])
		type_item.set_text(1, fld["type"])
		type_item.set_custom_bg_color(0, selected_field_fg)
		type_item.set_custom_color(0, selected_field_bg)
