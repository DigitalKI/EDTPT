extends Control

onready var log_entries = $LogDetailContainer/VBoxContainer/HBoxContainer/LogEntries
onready var log_details : Tree = $LogDetailContainer/VBoxContainer/HBoxContainer/LogDetails
onready var log_filter = $LogDetailContainer/VBoxContainer/ToolBarContainer/EventTypeFilter

var journal_event = preload("res://TabScreens/journalreader/JournalEvent.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	data_reader.connect("thread_completed_get_log_objects", self, "_on_DataReader_thread_completed_get_log_objects")
	data_reader.connect("new_cached_events", self, "_on_DataReader_new_cached_events")

func initialize_journal_reader():
	data_reader.db_get_all_cmdrs()
	fill_event_type_filter()
	add_all_events_by_type()

func _on_LogEntries_item_selected(index):
	var journal_name = log_entries.get_item_text(index)
	# Let's reset the details text area
	log_details.scroll_to_item(log_details.get_root())
	var dataobject = data_reader.logobjects[journal_name]["dataobject"]
	clear_events()
	add_events(dataobject)

func _on_DataReader_thread_completed_get_log_objects():
	initialize_journal_reader()
	# Automatically display the last journal entries:
#	add_all_events_by_type()

func _on_DataReader_new_cached_events(_events):
#	clear_events(_events.size())
	add_events(_events)

func get_data_object_text(_current_logobject):
	if _current_logobject:
		var objtext = ""
		for log_obj in _current_logobject:
			if log_obj:
				for idx in log_obj.keys():
					objtext +=  String(idx) + " - " + String(log_obj.get(idx)) + "\n"
				objtext += "\n"
			objtext += "------------------------\n"
		return objtext

func clear_events(_limit = 0):
	var count = 0
	if _limit == 0:
		log_details.clear()
	else:
		for idx in range(log_details.get_child_count() - 1, -1, -1):
			if _limit > 0 && count > _limit:
				break
			if log_details.get_root().get_children():
				log_details.get_root().get_prev().free()
			count += 1

func add_all_events_by_type():
	clear_events()
	add_events(data_reader.get_all_db_events_by_type(get_all_selected_event_types()))

func get_all_selected_event_types():
	var selected_types := []
	for idx in log_filter.get_popup().get_item_count():
		if log_filter.get_popup().is_item_checked(idx):
			selected_types.append(log_filter.get_popup().get_item_text(idx))
	return selected_types

# Adds an event to the list using the event object
func add_events(_current_logobject : Array):
	var counter := 0
	var tree_root : TreeItem = log_details.get_root()
	if !tree_root:
		log_details.set_column_titles_visible(true)
		log_details.set_column_title(0, "timestamp")
		log_details.set_column_expand(0, false)
		log_details.set_column_min_width(0, 140.0)
		log_details.set_column_title(1, "event")
		log_details.set_column_expand(1, false)
		log_details.set_column_min_width(1, 150.0)
		log_details.set_column_title(2, "details")
		log_details.set_column_expand(2, true)
		log_details.set_column_min_width(2, 150.0)
		tree_root = log_details.create_item()
	if _current_logobject:
		for log_obj in _current_logobject:
			if log_obj is Dictionary:
				var objtext : String = ""
				var evt := log_details.create_item(tree_root)
				counter += 1
				if log_obj.has("event"):
					evt.set_text(1, log_obj["event"])
				if log_obj.has("timestamp"):
					var date : DateTime = DateTime.new(log_obj["timestamp"])
					evt.set_text(0, date.to_string())
				for idx in log_obj.keys():
					if !["event", "timestamp", "Id", "CMDRId", "FileheaderId"].has(idx):
						var value = "" if log_obj[idx] == null else String(log_obj[idx])
						objtext +=  String(idx) + " - " + value + " | "
				evt.set_text(2, objtext.trim_suffix(" | "))
				evt.set_tooltip(2, objtext.trim_suffix(" | ").replace("|", "\n").replace("},{", "}\n{"))
			if counter > 1000:
				break

func fill_event_type_filter():
	log_filter.get_popup().clear()
	log_filter.get_popup().add_item("Select all")
	log_filter.get_popup().add_item("Select none")
	for evt_tpy in data_reader.evt_types:
		log_filter.get_popup().add_check_item(evt_tpy)
		var last_idx = log_filter.get_popup().get_item_count() - 1
		log_filter.get_popup().set_item_checked(last_idx, true)
	log_filter.get_popup().connect("id_pressed",self,"_on_filter_selected")

func _on_filter_selected(_index):
	var popup : PopupMenu = log_filter.get_popup()
	popup.set_item_checked(_index, !log_filter.get_popup().is_item_checked(_index))
	var _lst_event_types : Array = []
	for _itm_idx in popup.get_item_count():
		if popup.get_item_text(_index) == "Select none":
			popup.set_item_checked(_itm_idx, false)
		if popup.get_item_text(_index) == "Select all":
			popup.set_item_checked(_itm_idx, true)
			_lst_event_types.append(popup.get_item_text(_itm_idx))
		elif popup.is_item_checked(_itm_idx):
			_lst_event_types.append(popup.get_item_text(_itm_idx))
	add_all_events_by_type()

func _on_DisplayByEventFile_toggled(button_pressed):
	log_details.scroll_to_item(log_details.get_root())
	if button_pressed:
		log_entries.visible = true
	else:
		log_entries.visible = false
		add_all_events_by_type()

func _on_ClearDatabase_pressed():
	data_reader.clean_database()
	data_reader._ready()

func _on_BtUpdate_pressed():
#	data_reader.update_events_from_last_log()
	data_reader.update_events_from_last_log_threaded()
