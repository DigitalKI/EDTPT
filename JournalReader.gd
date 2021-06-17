extends Control

onready var log_entries = $HBoxContainer/LogEntries
onready var log_details = $HBoxContainer/LogDetailContainer/LogDetails
onready var datareader : DataReader = $DataReader


# Called when the node enters the scene tree for the first time.
func _ready():
#	var log_files = datareader.get_files_threaded()
	datareader.get_files()
	for file_log in datareader.logfiles:
		log_entries.add_item(file_log)

func _on_LogEntries_item_selected(index):
	var text = log_entries.get_item_text(index)
	# Let's reset the details text area
	log_details.scroll_to_line(0)
	log_details.text = ""
	datareader.get_log_objects_threaded(text)


func _on_DataReader_thread_completed_get_log_objects():
	if datareader.current_logobject:
		var objtext = ""
		for log_obj in datareader.current_logobject:
			if log_obj:
				for idx in log_obj.keys():
					objtext +=  String(idx) + " - " + String(log_obj.get(idx)) + "\n"
				objtext += "\n"
			objtext += "------------------------\n"
		log_details.text = objtext
