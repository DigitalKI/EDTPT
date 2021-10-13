extends Control

onready var event_tabs : TabContainer = $HBoxContainer/TabContainer
onready var saved_views : ItemList = $HBoxContainer/TabContainer/SavedViews/VBoxViews/SavedViewsList
onready var edit_button : Button = $HBoxContainer/TabContainer/SavedViews/VBoxViews/HBoxContainer/BtEdit
onready var delete_button : Button = $HBoxContainer/TabContainer/SavedViews/VBoxViews/HBoxContainer/BtDelete
onready var delete_confirmation : ConfirmationDialog = $HBoxContainer/TabContainer/SavedViews/VBoxViews/SavedViewsList/DeleteConfirmationDialog
onready var view_title : LineEdit = $HBoxContainer/TabContainer/SavedViews/VBoxViews/HBoxContainer/TbViewTitle
onready var event_types_table : EventTypesTable = $HBoxContainer/TabContainer/EventTypes
onready var events_fields : EventFields = $HBoxContainer/TabContainer/EventFields
onready var visual_rules : VisualRules = $HBoxContainer/TabContainer/VisualRules
onready var query_view: TextEdit = $HBoxContainer/TabContainer/QueryView/ResultingQuery
onready var results_table : Tree = $HBoxContainer/ResultsTable
onready var popup_results : PopupResultsDetail = $HBoxContainer/ResultsTable/PopupResultsDetail
onready var popup_rules : PopupMenu = $HBoxContainer/ResultsTable/PopupVisualRules

var views_data : Dictionary = {}
var current_query_structure_name : String = ""
var query_structure : Dictionary = {}
var edit_mode : String = ""

func _ready():
	pass

func _on_TbViewTitle_text_entered(new_text):
	if edit_mode.empty():
		saved_views.add_item(new_text)
		saved_views.select(saved_views.get_item_count() - 1)
		current_query_structure_name = new_text
		views_data[new_text] = {"structure": {}, "display": []}
		query_structure = views_data[new_text]
		events_fields.query_structure = query_structure
		view_title.text = ""
	else:
		views_data.erase(edit_mode)
		views_data[new_text] = query_structure
		for itm in saved_views.get_selected_items():
			saved_views.set_item_text(itm, new_text)
		current_query_structure_name = new_text
		edit_mode = ""
		view_title.text = ""
		data_reader.settings_manager.save_setting("query_views", views_data)
	edit_button.disabled = false
	delete_button.disabled = false

func _on_BtDelete_pressed():
	delete_confirmation.show()

func _on_BtEdit_pressed():
	for itm in saved_views.get_selected_items():
		view_title.text = saved_views.get_item_text(itm)
	edit_mode = view_title.text
	edit_button.disabled = true
	delete_button.disabled = true

func _on_ConfirmationDialog_confirmed():
	query_structure.clear()
	views_data.erase(current_query_structure_name)
	for itm in saved_views.get_selected_items():
		saved_views.remove_item(itm)
	events_fields.clear()
	data_reader.settings_manager.save_setting("query_views", views_data)

func _on_SavedViewsList_item_selected(index):
	current_query_structure_name = saved_views.get_item_text(index)
	query_structure = views_data[current_query_structure_name]
	events_fields.query_structure = query_structure
	visual_rules.query_structure = query_structure
	events_fields.clear()
	for tablename in query_structure["structure"].keys():
		var selected_event_color := event_types_table.get_event_type_color_by_text(tablename)
		events_fields.query_structure_to_ui(tablename, selected_event_color)
	if !query_structure.has("query"):
		query_view.text = data_reader.query_builder.query_structure_to_select(query_structure["structure"])
	elif query_structure["query"].empty():
		query_view.text = data_reader.query_builder.query_structure_to_select(query_structure["structure"])
	else:
		query_view.text = query_structure["query"]
	get_result_table(query_view.text + " LIMIT 1000")

func _on_SavedViewsList_item_activated(index):
	pass

func _on_EventTypes_event_type_selected(event_type, event_color):
	if query_structure["structure"].size() < 5:
		if !events_fields.get_event_types().has(event_type):
			events_fields.add_events_fields(event_type, event_color)
			event_tabs.current_tab = 2

func _on_EventFields_query_changed(sql_query):
	query_view.text = sql_query
	data_reader.settings_manager.save_setting("query_views", views_data)
	get_result_table(sql_query + " LIMIT 1000")

func _on_EventFields_clear_all():
	events_fields.clear()
	results_table.clear()
	query_view.text = ""

func _on_BtApplySql_pressed():
	query_structure["query"] = query_view.text
	data_reader.settings_manager.save_setting("query_views", views_data)
	get_result_table(query_view.text + " LIMIT 1000")

func initialize_builder():
	saved_views.clear()
	event_types_table.list_all_tables()
	query_structure.clear()
	events_fields.initialize_event_fields()
	list_saved_views()

func list_saved_views():
	var loaded_views = data_reader.settings_manager.get_setting("query_views")
	if loaded_views is Dictionary:
		views_data = loaded_views
		for view in views_data.keys():
			saved_views.add_item(view)

func get_result_table(_events_query : String):
	var events := data_reader.dbm.db_execute_select(_events_query)
	results_table.clear()
	results_table.set_column_titles_visible(true)
	if !events.empty():
		results_table.columns = events[0].size()
		for col_idx in  events[0].size():
			results_table.set_column_title(col_idx, events[0].keys()[col_idx])
			results_table.set_column_min_width(col_idx, 75)
	var results_table_root : TreeItem = results_table.create_item()
	for evt in events:
		var type_item : TreeItem = results_table.create_item(results_table_root)
		var col_idx = 0
		for col in evt.keys():
			type_item.set_text(col_idx, "" if !evt[col] else String(evt[col]))
			col_idx += 1

func _on_ResultsTable_gui_input(event):
	if event is InputEventKey:
		if event.scancode ==  KEY_C && event.control:
			if results_table.get_selected():
				OS.clipboard = results_table.get_selected().get_text(results_table.get_selected_column())

func _on_ResultsTable_item_activated():
	var result_field : String = TreeHelper.get_selected_column_title(results_table)
	var result_text : String = TreeHelper.get_selected_text(results_table)
	if result_text.begins_with("[") || result_text.begins_with("{"):
		var data = parse_json(result_text)
		popup_results.fill_table(result_field, data)
		popup_results.popup_centered()

func _on_ResultsTable_item_rmb_selected(position):
	popup_rules.popup(Rect2(results_table.rect_position + position, popup_rules.rect_size))

func _on_PopupResultsDetail_field_selected(addr):
	visual_rules.add_field_addr(addr, Color(1,1,1))
	event_tabs.current_tab = 3

func _on_PopupVisualRules_id_pressed(id):
	if id == 0:
		var selected_field : String = TreeHelper.get_selected_column_title(results_table)
		visual_rules.add_field_addr([selected_field], Color(1,1,1))

