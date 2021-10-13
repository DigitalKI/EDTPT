extends Control

onready var log_entries : ItemList = $LogDetailContainer/VBoxContainer/HBoxContainer/LogEntries
onready var log_details : Tree = $LogDetailContainer/VBoxContainer/HBoxContainer/LogDetails
onready var log_filter : MenuButton = $LogDetailContainer/VBoxContainer/ToolBarContainer/EventTypeFilter
onready var log_filter_popup : PopupMenu = log_filter.get_popup()
onready var time_range : MenuButton = $LogDetailContainer/VBoxContainer/ToolBarContainer/TimeRange
onready var time_range_popup : PopupMenu = time_range.get_popup()
onready var autoupdate_toggle : CheckButton = $LogDetailContainer/VBoxContainer/ToolBarContainer/BtUpdate

var journal_events := []
var timerange := 24

# Called when the node enters the scene tree for the first time.
func _ready():
	data_reader.connect("new_cached_events", self, "_on_DataReader_new_cached_events")
	if !time_range_popup.is_connected("id_pressed", self, "_on_timerange_selected"):
		time_range_popup.connect("id_pressed",self,"_on_timerange_selected")

func initialize_journal_reader():
	data_reader.db_get_all_cmdrs()
	clear_events()
	fill_event_type_filter()
	add_all_events_by_type()
	data_reader.autoupdate = autoupdate_toggle.pressed

func _on_LogEntries_item_selected(index):
	var journal_name = log_entries.get_item_text(index)
	# Let's reset the details text area
	log_details.scroll_to_item(log_details.get_root())
	var dataobject = logger.logobjects[journal_name]["dataobject"]
	clear_events()
	add_events(dataobject)

# This is to allow to copy to clipboard the content of the journal entry
func _on_LogDetails_gui_input(event):
	TreeHelper.cell_to_clipboard(event, log_details, "json")

func _on_DataReader_new_cached_events(_events: Array):
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

func get_start_timestamp():
	var startfrom : DateTime = DateTime.new()
	startfrom.date_add("hour", -timerange)
	if timerange == 0:
		startfrom.date_add("year", -50)
	return startfrom._to_string(true)

func add_all_events_by_type():
	journal_events = data_reader.get_all_db_events_by_type(get_all_selected_event_types(), 0, 0, get_start_timestamp())
	clear_events()
	add_events(journal_events)

func get_all_selected_event_types() -> Array:
	var selected_types := []
	for idx in log_filter_popup.get_item_count():
		if log_filter_popup.is_item_checked(idx):
			selected_types.append(log_filter_popup.get_item_text(idx))
	return selected_types

# Adds an event to the list using the event object
# evey new event is put at the beginning of the tree
func add_events(_current_logobject : Array, _filter : bool = false):
	var current_event_types := get_all_selected_event_types()
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
		logger.log_event("Showing %s events in journal reader" % _current_logobject.size())
		var start_time = get_start_timestamp()
		for log_obj in _current_logobject:
			if log_obj is Dictionary:
				var evt : TreeItem
				if log_obj.has("timestamp"):
				# we skip this entry if it's before the oldest timestamp we're looking for
				# We also skip by selected event type (by default all events are selected
					if log_obj["timestamp"] < start_time || !current_event_types.has(log_obj["event"]):
						continue
					evt = log_details.create_item(tree_root)
					evt.move_to_top() # here it moves it at the top IMPORTANT
					evt.set_text(0, DateTime.format_timestamp(log_obj["timestamp"]))
					evt.set_tooltip(0, log_obj["timestamp"])
				if log_obj.has("event"):
					evt.set_text(1, log_obj["event"])
				var objtext : String = ""
				for idx in log_obj.keys():
					if !["event", "timestamp", "Id", "CMDRId", "FileheaderId"].has(idx):
						var value = DataConverter.get_value(log_obj[idx])
						objtext +=  String(idx) + " - " + value + " | "
				evt.set_text(2, objtext.trim_suffix(" | "))
				evt.set_tooltip(2, objtext.trim_suffix(" | ").replace("|", "\n").replace("},{", "}\n{"))
				evt.set_meta("json", log_obj)

func fill_event_type_filter():
	log_filter_popup.clear()
	log_filter_popup.add_item("Select all")
	log_filter_popup.add_item("Select none")
	for evt_tpy in data_reader.evt_types:
		log_filter_popup.add_check_item(evt_tpy)
		var last_idx = log_filter_popup.get_item_count() - 1
		log_filter_popup.set_item_checked(last_idx, true)
	if !log_filter_popup.is_connected("id_pressed", self, "_on_filter_selected"):
		log_filter_popup.connect("id_pressed",self,"_on_filter_selected")

func _on_filter_selected(_index):
	log_filter_popup.set_item_checked(_index, !log_filter_popup.is_item_checked(_index))
	var _lst_event_types : Array = []
	for _itm_idx in log_filter_popup.get_item_count():
		if log_filter_popup.get_item_text(_index) == "Select none":
			log_filter_popup.set_item_checked(_itm_idx, false)
		if log_filter_popup.get_item_text(_index) == "Select all":
			log_filter_popup.set_item_checked(_itm_idx, true)
			_lst_event_types.append(log_filter_popup.get_item_text(_itm_idx))
		elif log_filter_popup.is_item_checked(_itm_idx):
			_lst_event_types.append(log_filter_popup.get_item_text(_itm_idx))
	add_all_events_by_type()

func _on_timerange_selected(_id):
	timerange = _id
	clear_events()
	add_all_events_by_type()

func _on_DisplayByEventFile_toggled(button_pressed):
	log_details.scroll_to_item(log_details.get_root())
	if button_pressed:
		log_entries.visible = true
	else:
		log_entries.visible = false
		add_all_events_by_type()

func _on_BtUpdate_toggled(button_pressed):
	data_reader.autoupdate = button_pressed

