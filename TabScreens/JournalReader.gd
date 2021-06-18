extends Control

onready var log_entries = $LogDetailContainer/HBoxContainer/LogEntries
onready var log_details = $LogDetailContainer/HBoxContainer/LogDetails


# Called when the node enters the scene tree for the first time.
func _ready():
	data_reader.connect("thread_completed_get_log_objects", self, "_on_DataReader_thread_completed_get_log_objects")

func _on_LogEntries_item_selected(index):
	var journal_name = log_entries.get_item_text(index)
	# Let's reset the details text area
	log_details.scroll_to_line(0)
	log_details.text = ""
	show_data_object(data_reader.logobjects[journal_name]["dataobject"])


func _on_DataReader_thread_completed_get_log_objects():
	for logobj in data_reader.logobjects:
		log_entries.add_item(logobj["filename"])

func show_data_object(_current_logobject):
	if _current_logobject:
		var objtext = ""
		for log_obj in _current_logobject:
			if log_obj:
				for idx in log_obj.keys():
					objtext +=  String(idx) + " - " + String(log_obj.get(idx)) + "\n"
				objtext += "\n"
			objtext += "------------------------\n"
		log_details.text = objtext
