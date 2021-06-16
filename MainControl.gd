extends Control

onready var log_entries = $HBoxContainer/LogEntries
onready var log_details = $HBoxContainer/LogDetailContainer/LogDetails


# Called when the node enters the scene tree for the first time.
func _ready():
	var log_files = $DataReader.get_files()
	for file_log in log_files:
		$HBoxContainer/LogEntries.add_item(file_log)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_LogEntries_item_selected(index):
	var text = log_entries.get_item_text(index)
	var log_obj_arr = $DataReader.get_log_objects(text)
	if log_obj_arr:
		for log_obj in log_obj_arr:
			if log_obj:
				for idx in log_obj.keys():
					log_details.text +=  String(idx) + " " + String(log_obj.get(idx))
					log_details.newline()
